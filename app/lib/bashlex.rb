class Bashlex
  class PythonError < StandardError; end

  def self.parse(string)
    result = nil
    stdout_str, stderr_str, status = Open3.capture3(
      'python3',
      Rails.root.join('app/lib/call_bashlex.py'),
      stdin_data: string
    )
    raise PythonError, stderr_str if stderr_str != ''

    JSON.parse(stdout_str)
  end
end
