# # Modules: Deployment
# This module is automatically loaded for all Mina projects.

# ## Settings
# Any and all of these settings can be overriden in your `deploy.rb`.

# ### releases_path
# (default: 'releases')
set_default :releases_path, "releases"

# ### shared_path
# (default: 'shared')
set_default :shared_path, "shared"

# ### current_path
# (default: 'current_path')
set_default :current_path, "current"

# ### lock_file
# Name of the file to generate while a deploy is currently ongoing.
# (default: 'deploy.lock')
set_default :lock_file, "deploy.lock"

# ### keep_releases
# Number of releases to keep when doing the `deploy:cleanup` task.
# (default: 5)
set_default :keep_releases, 5

namespace :deploy do
  # ## Tasks

  # ### deploy:force_unlock
  # Forces a deploy unlock by deleting the lock file.
  #
  #     $ mina deploy:force_unlock
  #
  # You can also combine that task with `deploy`:
  #
  #     $ mina deploy:force_unlock deploy

  desc "Forces a deploy unlock."
  task :force_unlock do
    queue %{echo "-----> Unlocking"}
    queue echo_cmd %{rm -f "#{deploy_to}/#{lock_file}"}
  end

  # ### deploy:link_shared_paths
  # Links the shared paths in the `shared_paths` setting.

  desc "Links paths set in :shared_paths."
  task :link_shared_paths do
    dirs = settings.shared_paths!.map { |file| File.dirname("./#{file}") }.uniq

    cmds = dirs.map do |dir|
      echo_cmd %{mkdir -p "#{dir}"}
    end

    cmds += shared_paths.map do |file|
      [
        echo_cmd(%{rm -rf "./#{file}"}),
        echo_cmd(%{ln -s "#{deploy_to}/#{shared_path}/#{file}" "./#{file}"})
      ]
    end

    queue %{
      #{print_str '-> Symlinking shared paths'}
      #{cmds.flatten.join(" &&\n")}
    }
  end

  # ### deploy:cleanup
  # Cleans up old releases.
  #
  # By default, the last 5 releases are kept on each server (though you can
  # change this with the keep_releases setting).  All other deployed revisions
  # are removed from the servers."

  desc "Clean up old releases."
  task :cleanup do
    queue %{
      #{print_str "-> Cleaning up old releases (keeping " + keep_releases + "!})"}
      #{echo_cmd %{cd "#{deploy_to!}/#{releases_path!}" || exit 15}}
      #{echo_cmd %{count=`ls -1d [0-9]* | sort -rn | wc -l`}}
      #{echo_cmd %{remove=$((count > #{keep_releases} ? count - #{keep_releases} : 0))}}
      #{echo_cmd %{ls -1d [0-9]* | sort -rn | tail -n $remove | xargs rm -rf {}}}
    }
  end
end

# ### setup
# Sets up a site's directory structure.

desc "Sets up a site."
task :setup do
  set_default :term_mode, :pretty

  settings.deploy_to!

  user = settings.user? ? "#{settings.user}" : "username"

  queue %{
    #{print_str "-> Setting up #{deploy_to}"} && (
      #{echo_cmd %{mkdir -p "#{deploy_to}"}} &&
      #{echo_cmd %{chown -R `whoami` "#{deploy_to}"}} &&
      #{echo_cmd %{chmod g+rx,u+rwx "#{deploy_to}"}} &&
      #{echo_cmd %{cd "#{deploy_to}"}} &&
      #{echo_cmd %{mkdir -p "#{releases_path}"}} &&
      #{echo_cmd %{chmod g+rx,u+rwx "#{releases_path}"}} &&
      #{echo_cmd %{mkdir -p "#{shared_path}"}} &&
      #{echo_cmd %{chmod g+rx,u+rwx "#{shared_path}"}} &&
      echo "" &&
      #{echo_cmd %{ls -la "#{deploy_to}"}} &&
      echo "" &&
      #{print_str "-> Done."}
    ) || (
      echo "! ERROR: Setup failed."
      echo "! Ensure that the path '#{deploy_to}' is accessible to the SSH user."
      echo "! Try doing:"
      echo "!    sudo mkdir -p \\"#{deploy_to}\\" && sudo chown -R #{user} \\"#{deploy_to}\\""
    )
  }
end

# ### run[]
# Runs a command on a server.
#
#     $ mina run[tail -f logs.txt]

desc "Runs a command in the server."
task :run, [:command] => [:environment] do |t, args|
  command = args[:command]
  unless command
    puts %[You need to provide a command. Try: mina "run[ls -la]"]
    exit 1
  end

  queue %[cd #{deploy_to!} && #{command}]
end
