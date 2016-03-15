# @author Mike Bland (michael.bland@gsa.gov)

require 'English'
require 'fileutils'

module GuidesStyle18F
  TEMPLATE_FILES = %w(
    _pages/add-a-new-page/make-a-child-page.md
    _pages/add-a-new-page.md
    _pages/add-images.md
    _pages/advanced-features.md
    _pages/github-setup.md
    _pages/images.png
    _pages/post-your-guide.md
    _pages/update-the-config-file/understanding-baseurl.md
    _pages/update-the-config-file.md
    images/18f-pages.png
    images/description.png
    images/gh-add-guide.png
    images/gh-branches-link.png
    images/gh-default-branch.png
    images/gh-settings-button.png
    images/gh-webhook.png
  )

  def self.clear_template_files_and_create_new_repository(
    basedir, outstream = $stdout)
    remove_template_files basedir, outstream
    delete_create_repo_command_from_go_script basedir, outstream
    create_new_git_repository basedir, outstream
  end

  def self.remove_template_files(basedir, outstream)
    Dir.chdir basedir do
      outstream.puts 'Clearing Guides Template files.'
      files = TEMPLATE_FILES.map { |f| File.join basedir, f }
        .select { |f| File.exist? f }
      File.delete(*files)
    end
  end

  def self.delete_create_repo_command_from_go_script(basedir, outstream)
    Dir.chdir basedir do
      outstream.puts 'Removing `:create_repo` command from the `./go` script.'
      go_script = File.join basedir, 'go'
      content = File.read go_script
      match = /\ndef_command\(\n  :create_repo,.*?end\n/m.match content
      content = "#{match.pre_match}#{match.post_match}" unless match.nil?
      File.write go_script, content
    end
  end

  GIT_COMMANDS = {
    'Creating a new git repository.' => 'git init',
    'Creating 18f-pages branch.' => 'git checkout -b 18f-pages',
    'Adding files for initial commit.' => 'git add .',
  }

  def self.create_new_git_repository(basedir, outstream)
    Dir.chdir basedir do
      outstream.puts 'Removing old git repository.'
      FileUtils.rm_rf '.git'
      GIT_COMMANDS.each do |description, command|
        outstream.puts description
        exec_cmd_capture_output command, outstream
      end
      outstream.puts "All done! Run \'git commit\' to create your first commit."
    end
  end
  private_class_method :create_new_git_repository

  def self.exec_cmd_capture_output(command, outstream)
    opts = { out: outstream, err: outstream }
    exit $CHILD_STATUS.exitstatus unless system command, opts
  end
end
