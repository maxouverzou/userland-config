{ writers, ... }:
writers.writePython3Bin "git-traverse" { } ''
  import argparse
  import subprocess
  import sys
  import json
  from pathlib import Path
  from datetime import datetime
  from dataclasses import dataclass
  import tempfile
  import shutil


  @dataclass
  class CommandResult:
      exit_code: int
      stdout: str
      stderr: str
      duration: float


  @dataclass
  class TestResult:
      commit: str
      commit_message: str
      passed: bool
      command_result: CommandResult
      timestamp: str


  class GitTraverseError(Exception):
      """Base exception for git traverse"""
      pass


  class PreFlightError(GitTraverseError):
      """Errors that prevent execution from starting"""
      pass


  class GitOperations:
      """Git-specific operations"""

      @staticmethod
      def is_git_repo():
          """Check if current directory is a git repository"""
          result = subprocess.run(
              ['git', 'rev-parse', '--git-dir'],
              capture_output=True,
              text=True
          )
          return result.returncode == 0

      @staticmethod
      def is_clean_tree():
          """Check if working tree is clean"""
          result = subprocess.run(
              ['git', 'status', '--porcelain'],
              capture_output=True,
              text=True
          )
          return result.returncode == 0 and not result.stdout.strip()

      @staticmethod
      def get_commit_list(start, end):
          """Get list of commits from start to end (inclusive)"""
          # Using rev-list with ^start to get commits after start up to end
          result = subprocess.run(
              ['git', 'rev-list', '--reverse', f'{start}..{end}'],
              capture_output=True,
              text=True,
              check=True
          )
          commits = result.stdout.strip().split('\n')
          return [c for c in commits if c]

      @staticmethod
      def create_worktree(commit):
          """Create a temporary worktree for the given commit"""
          tmpdir = tempfile.mkdtemp(prefix='git-traverse-')
          worktree_path = Path(tmpdir)
          subprocess.run(
              ['git', 'worktree', 'add', str(worktree_path), commit],
              capture_output=True,
              check=True
          )
          return worktree_path

      @staticmethod
      def remove_worktree(path):
          """Remove a worktree"""
          try:
              subprocess.run(
                  ['git', 'worktree', 'remove', str(path), '--force'],
                  capture_output=True,
                  check=True
              )
          except subprocess.CalledProcessError:
              # Fallback to manual removal if git worktree remove fails
              shutil.rmtree(path, ignore_errors=True)

      @staticmethod
      def checkout(commit):
          """Checkout a commit"""
          subprocess.run(
              ['git', 'checkout', commit],
              capture_output=True, check=True)

      @staticmethod
      def get_current_commit():
          """Get current HEAD commit hash"""
          result = subprocess.run(
              ['git', 'rev-parse', 'HEAD'],
              capture_output=True,
              text=True,
              check=True
          )
          return result.stdout.strip()

      @staticmethod
      def get_commit_message(commit):
          """Get first line of commit message"""
          result = subprocess.run(
              ['git', 'log', '-1', '--pretty=%s', commit],
              capture_output=True,
              text=True,
              check=True
          )
          return result.stdout.strip()

      @staticmethod
      def commit_exists(commit):
          """Check if a commit exists"""
          result = subprocess.run(
              ['git', 'rev-parse', '--verify', commit],
              capture_output=True,
              text=True
          )
          return result.returncode == 0


  class CommandRunner:
      """Execute commands and capture output"""

      @staticmethod
      def run_command(cmd, cwd, timeout=300):
          """Run a command and return result"""
          start_time = datetime.now()
          try:
              result = subprocess.run(
                  cmd,
                  shell=True,
                  cwd=str(cwd),
                  capture_output=True,
                  text=True,
                  timeout=timeout
              )
              duration = (datetime.now() - start_time).total_seconds()
              return CommandResult(
                  exit_code=result.returncode,
                  stdout=result.stdout,
                  stderr=result.stderr,
                  duration=duration
              )
          except subprocess.TimeoutExpired as e:
              duration = (datetime.now() - start_time).total_seconds()
              stderr_msg = "Command timed out after " + str(timeout) + "s\n"
              if e.stderr:
                  stderr_msg += e.stderr.decode()
              return CommandResult(
                  exit_code=124,  # Standard timeout exit code
                  stdout=e.stdout.decode() if e.stdout else "",
                  stderr=stderr_msg,
                  duration=duration
              )

      @staticmethod
      def save_output(commit, result, output_dir):
          """Save command output to file"""
          output_dir = Path(output_dir)
          output_dir.mkdir(parents=True, exist_ok=True)

          status = 'passed' if result.command_result.exit_code == 0 else 'failed'
          filename = f'{commit}.{status}.txt'
          filepath = output_dir / filename

          with open(filepath, 'w') as f:
              f.write(f'Commit: {commit}\n')
              f.write(f'Message: {result.commit_message}\n')
              f.write(f'Timestamp: {result.timestamp}\n')
              f.write(f'Duration: {result.command_result.duration:.2f}s\n')
              f.write(f'Exit Code: {result.command_result.exit_code}\n')
              f.write('\n=== STDOUT ===\n')
              f.write(result.command_result.stdout)
              f.write('\n\n=== STDERR ===\n')
              f.write(result.command_result.stderr)


  class LinearRunner:
      """Linear execution mode - test all commits in range"""

      def __init__(self, args):
          self.args = args
          self.git_ops = GitOperations()
          self.cmd_runner = CommandRunner()

      def run(self):
          """Run tests linearly across commit range"""
          commits = self.git_ops.get_commit_list(
              self.args.start, self.args.end)

          if not commits:
              msg = f"No commits found between {self.args.start}"
              msg += f" and {self.args.end}"
              print(msg)
              return []

          print(f"Testing {len(commits)} commits...")

          original_commit = None
          if not self.args.worktree:
              original_commit = self.git_ops.get_current_commit()

          results = []
          try:
              for i, commit in enumerate(commits, 1):
                  print(f"\n[{i}/{len(commits)}] Testing commit {commit[:8]}...")
                  result = self._test_commit(commit)
                  results.append(result)

                  status = '✓ PASSED' if result.passed else '✗ FAILED'
                  print(f"  {status} ({result.command_result.duration:.2f}s)")

          finally:
              if not self.args.worktree and original_commit:
                  print(f"\nRestoring original commit {original_commit[:8]}...")
                  self.git_ops.checkout(original_commit)

          return results

      def _test_commit(self, commit):
          """Test a single commit"""
          worktree_path = None
          try:
              if self.args.worktree:
                  worktree_path = self.git_ops.create_worktree(commit)
                  work_dir = worktree_path
              else:
                  self.git_ops.checkout(commit)
                  work_dir = Path.cwd()

              # Run setup command if specified
              if self.args.setup:
                  self.cmd_runner.run_command(
                      self.args.setup, work_dir, self.args.timeout)

              # Run test command
              cmd_result = self.cmd_runner.run_command(
                  self.args.command, work_dir, self.args.timeout)

              # Run teardown command if specified
              if self.args.teardown:
                  self.cmd_runner.run_command(
                      self.args.teardown, work_dir, self.args.timeout)

              commit_msg = self.git_ops.get_commit_message(commit)
              result = TestResult(
                  commit=commit,
                  commit_message=commit_msg,
                  passed=(cmd_result.exit_code == 0),
                  command_result=cmd_result,
                  timestamp=datetime.now().isoformat()
              )

              self.cmd_runner.save_output(commit, result, self.args.output_dir)
              return result

          finally:
              if worktree_path:
                  self.git_ops.remove_worktree(worktree_path)


  class BisectRunner:
      """Bisect mode - binary search for breaking commit"""

      def __init__(self, args):
          self.args = args
          self.git_ops = GitOperations()
          self.cmd_runner = CommandRunner()
          self.results = []

      def run(self):
          """Run bisect to find first failing commit"""
          commits = self.git_ops.get_commit_list(
              self.args.good, self.args.bad)

          if not commits:
              msg = f"No commits found between {self.args.good}"
              msg += f" and {self.args.bad}"
              print(msg)
              return []

          print(f"Bisecting {len(commits)} commits...")

          # Verify boundaries
          print(f"\nVerifying good commit {self.args.good[:8]}...")
          if not self._test_commit_passes(self.args.good):
              msg = f"Good commit {self.args.good} actually fails!"
              raise PreFlightError(msg)
          print("  ✓ Good commit passes")

          print(f"\nVerifying bad commit {self.args.bad[:8]}...")
          if self._test_commit_passes(self.args.bad):
              msg = f"Bad commit {self.args.bad} actually passes!"
              raise PreFlightError(msg)
          print("  ✗ Bad commit fails")

          original_commit = None
          if not self.args.worktree:
              original_commit = self.git_ops.get_current_commit()

          try:
              # Binary search
              left = 0
              right = len(commits) - 1

              while right - left > 1:
                  mid = (left + right) // 2
                  mid_commit = commits[mid]

                  step = len(self.results) - 1
                  pos = f"{mid + 1}/{len(commits)}"
                  print(f"\n[Step {step}] Testing {mid_commit[:8]} ({pos})...")

                  if self._test_commit_passes(mid_commit):
                      left = mid
                      print("  ✓ PASSED - moving good boundary")
                  else:
                      right = mid
                      print("  ✗ FAILED - moving bad boundary")

              breaking_commit = commits[right]
              last_good = commits[left]

              print(f"\n{'='*60}")
              print(f"First failing commit: {breaking_commit[:8]}")
              print(f"Last good commit: {last_good[:8]}")
              print(f"{'='*60}")

          finally:
              if not self.args.worktree and original_commit:
                  print(f"\nRestoring original commit {original_commit[:8]}...")
                  self.git_ops.checkout(original_commit)

          return self.results

      def _test_commit_passes(self, commit):
          """Test if a commit passes (returns True/False)"""
          result = self._test_commit(commit)
          self.results.append(result)
          return result.passed

      def _test_commit(self, commit):
          """Test a single commit (same as LinearRunner)"""
          worktree_path = None
          try:
              if self.args.worktree:
                  worktree_path = self.git_ops.create_worktree(commit)
                  work_dir = worktree_path
              else:
                  self.git_ops.checkout(commit)
                  work_dir = Path.cwd()

              if self.args.setup:
                  self.cmd_runner.run_command(
                      self.args.setup, work_dir, self.args.timeout)

              cmd_result = self.cmd_runner.run_command(
                  self.args.command, work_dir, self.args.timeout)

              if self.args.teardown:
                  self.cmd_runner.run_command(
                      self.args.teardown, work_dir, self.args.timeout)

              commit_msg = self.git_ops.get_commit_message(commit)
              result = TestResult(
                  commit=commit,
                  commit_message=commit_msg,
                  passed=(cmd_result.exit_code == 0),
                  command_result=cmd_result,
                  timestamp=datetime.now().isoformat()
              )

              self.cmd_runner.save_output(commit, result, self.args.output_dir)
              return result

          finally:
              if worktree_path:
                  self.git_ops.remove_worktree(worktree_path)


  class ResultReporter:
      """Generate summary reports"""

      @staticmethod
      def generate_reports(results, mode, args):
          """Generate both JSON and text reports"""
          output_dir = Path(args.output_dir)
          output_dir.mkdir(parents=True, exist_ok=True)

          # JSON report
          json_data = {
              'mode': mode,
              'command': args.command,
              'total_commits': len(results),
              'passed': sum(1 for r in results if r.passed),
              'failed': sum(1 for r in results if not r.passed),
              'results': [
                  {
                      'commit': r.commit,
                      'message': r.commit_message,
                      'passed': r.passed,
                      'exit_code': r.command_result.exit_code,
                      'duration': r.command_result.duration,
                      'timestamp': r.timestamp
                  }
                  for r in results
              ]
          }

          # Find first failure
          first_failure = next((r for r in results if not r.passed), None)
          if first_failure:
              json_data['first_failure'] = {
                  'commit': first_failure.commit,
                  'message': first_failure.commit_message
              }

          with open(output_dir / 'summary.json', 'w') as f:
              json.dump(json_data, f, indent=2)

          # Text report
          with open(output_dir / 'summary.txt', 'w') as f:
              f.write('Git Traverse Results\n')
              f.write('=' * 60 + '\n\n')
              f.write(f'Mode: {mode}\n')
              f.write(f'Command: {args.command}\n')
              f.write(f'Total commits tested: {len(results)}\n')
              f.write(f'Passed: {sum(1 for r in results if r.passed)}\n')
              f.write(f'Failed: {sum(1 for r in results if not r.passed)}\n\n')

              if first_failure:
                  f.write('First Failure:\n')
                  f.write(f'  Commit: {first_failure.commit}\n')
                  f.write(f'  Message: {first_failure.commit_message}\n\n')

              failed = [r for r in results if not r.passed]
              if failed:
                  f.write('Failed Commits:\n')
                  for r in failed:
                      f.write(f'  - {r.commit[:8]} - {r.commit_message}\n')

          print(f"\nResults saved to: {output_dir}")
          print("  - summary.json")
          print("  - summary.txt")
          print(f"  - {len(results)} output files")


  def verify_preconditions(args):
      """Verify all pre-flight conditions"""
      git_ops = GitOperations()

      if not git_ops.is_git_repo():
          raise PreFlightError("Not in a git repository")

      if not args.worktree and not git_ops.is_clean_tree():
          raise PreFlightError(
              "Working tree has uncommitted changes. "
              "Commit your changes or use --worktree flag."
          )

      # Verify commits exist
      if hasattr(args, 'start'):
          if not git_ops.commit_exists(args.start):
              raise PreFlightError(f"Start commit not found: {args.start}")
          if not git_ops.commit_exists(args.end):
              raise PreFlightError(f"End commit not found: {args.end}")
      else:
          if not git_ops.commit_exists(args.good):
              raise PreFlightError(f"Good commit not found: {args.good}")
          if not git_ops.commit_exists(args.bad):
              raise PreFlightError(f"Bad commit not found: {args.bad}")

      # Verify output directory is writable
      output_dir = Path(args.output_dir)
      try:
          output_dir.mkdir(parents=True, exist_ok=True)
      except Exception as e:
          raise PreFlightError(f"Cannot create output directory: {e}")


  def main():
      parser = argparse.ArgumentParser(
          description='Run commands across git commits to find when tests broke'
      )
      subparsers = parser.add_subparsers(dest='mode', required=True)

      # Common arguments
      common = argparse.ArgumentParser(add_help=False)
      common.add_argument('-c', '--command', required=True,
                          help='Command to run')
      common.add_argument('-o', '--output-dir',
                          default='./git-traverse-output',
                          help='Output directory')
      common.add_argument('-s', '--setup',
                          help='Setup command before test')
      common.add_argument('-t', '--teardown',
                          help='Teardown command after test')
      common.add_argument('-w', '--worktree', action='store_true',
                          help='Use dedicated worktree')
      common.add_argument('--timeout', type=int, default=300,
                          help='Command timeout in seconds')
      common.add_argument('-v', '--verbose', action='store_true',
                          help='Verbose output')

      # Linear mode
      linear = subparsers.add_parser(
          'linear', parents=[common],
          help='Run command on all commits in range')
      linear.add_argument('--start', required=True,
                          help='Start commit')
      linear.add_argument('--end', required=True,
                          help='End commit')

      # Bisect mode
      bisect = subparsers.add_parser(
          'bisect', parents=[common],
          help='Binary search for breaking commit')
      bisect.add_argument('--good', required=True,
                          help='Known good commit')
      bisect.add_argument('--bad', required=True,
                          help='Known bad commit')

      args = parser.parse_args()

      try:
          verify_preconditions(args)

          if args.mode == 'linear':
              runner = LinearRunner(args)
              results = runner.run()
          else:
              runner = BisectRunner(args)
              results = runner.run()

          ResultReporter.generate_reports(results, args.mode, args)

          # Exit with failure if any tests failed
          if any(not r.passed for r in results):
              sys.exit(1)

      except PreFlightError as e:
          print(f"Error: {e}", file=sys.stderr)
          sys.exit(1)
      except KeyboardInterrupt:
          print("\n\nInterrupted by user", file=sys.stderr)
          sys.exit(130)
      except Exception as e:
          print(f"Unexpected error: {e}", file=sys.stderr)
          import traceback
          traceback.print_exc()
          sys.exit(2)


  if __name__ == '__main__':
      main()
''
