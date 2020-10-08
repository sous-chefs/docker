# Reference: http://danger.systems/reference.html

# A pull request summary is required. Add a description of the pull request purpose.
# Changelog must be updated for each pull request that changes code.
# Warnings will be issued for:
#    Pull request with more than 400 lines of code changed
#    Pull reqest that change more than 5 lines without test changes
# Failures will be issued for:
#    Pull request without summary
#    Pull requests with code changes without changelog entry

def code_changes?
  code = %w(libraries attributes recipes resources files templates)
  code.each do |location|
    return true unless git.modified_files.grep(/#{location}/).empty?
  end
  false
end

def test_changes?
  tests = %w(spec test kitchen.yml kitchen.dokken.yml)
  tests.each do |location|
    return true unless git.modified_files.grep(/#{location}/).empty?
  end
  false
end

failure 'Please provide a summary of your Pull Request.' if github.pr_body.length < 10

warn 'This is a big Pull Request.' if git.lines_of_code > 400

warn 'This is a Table Flip.' if git.lines_of_code > 2000

# Require a CHANGELOG entry for non-test changes.
if !git.modified_files.include?('CHANGELOG.md') && code_changes?
  failure 'Please include a CHANGELOG entry.'
end

# Require Major Minor Patch version labels
unless github.pr_labels.grep /minor|major|patch/i
  warn 'Please add a release label to this pull request'
end

# A sanity check for tests.
if git.lines_of_code > 5 && code_changes? && !test_changes?
  warn 'This Pull Request is probably missing tests.'
end
