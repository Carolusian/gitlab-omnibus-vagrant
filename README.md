GitLab Setup Guide 
===
The guide shows a workflow of how to install, backup, restore and upgrade gitlab (community edition).

### Setup 1: Install
We use `vagrant` and `virtualbox` to provide a gitlab installation. Please make sure these two tools are on your server.

Firstly, `git clone` the Vagrantfile and relevant shell scripts from the following repo:
> <https://github.com/carolusian/gitlab-omnibus-vagrant> 

Then, provide proper settings of the our gitlab server's IP address and hostname and run `vagrant up`. The sample commands are provided:
<pre>git clone https://github.com/Carolusian/gitlab-omnibus-vagrant.git  {$desktop-path}/VMs/gitlab
cd {$desktop-path}/VMs/gitlab
cp config.yml.dist configy.yml
vi config.yml   # Then, input ip addr and hostname
vagrant up</pre>

If the environment is successfully setup, we can access gitlab through the server's hostname (make sure you have your LAN DNS pointing the hostname to the server's IP). For first time login, we need to update `root` user's password (the default password is `5iveL!fe`).

> NOTE: 
> We also need to make sure postfix works on the server. e.g. forget password function will send email to user's email address.

### Setup 2: Backup
We should backup both the `GitLab data` and the `vagrant box`

#### For `GitLab data`:
First, we need to login the guest system:
<pre>cd {$desktop-path}/VMs/gitlab
vagrant up
vagrant ssh</pre>
Then, we can use GitLab installation's command line tool
<pre>sudo gitlab-rake gitlab:backup:create</pre>

The backup file will be `{$TIMESTAMP}_gitlab_backup.tar` in `/var/opt/gitlab/backups/`

Move the backup file to host system.
<pre> sudo mv /var/opt/gitlab/backups/{$TIMESTAMP}_gitlab_backup.tar /vagrant/</pre>

It is recommended to use `cron` job to perform daily backup.
<pre>sudo su -
crontab -e
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1 > /tmp/gitlab-backup.log
* * * * * rsync -azvv /var/opt/gitlab/backups /vagrant/backups > /tmp/rsync.log</pre>

The above line schedules backup everyday at 2 AM.

#### For `vagrant box`:
In case we cannot successfully restore gitlab from a "gitlab backup", a packed vagrant box which contains all existing data and gitlab installation will be our last resort.

On the host server:
<pre>cd {$desktop-path}/VMs/gitlab
vagrant halt
vagrant package --output {$DATE}_gitlab_backup.box</pre>

Similarly, you can also use `cron` job on the host server to pack vagrant box, e.g.:
<pre>0 1 * * 6 cd {$desktop-path}/VMs/gitlab && vagrant halt && vagrant package --OUTPUT $(date +'%Y-%m-%d_gitlab_backup.box') > {$desktop-path}/VMs/gitlab/backup.log</pre>

The above line schedules vagrant packaging at 1 AM every Sunday

> NOTE:
> * Always backup before upgrade so that you can restore to previous installation if upgrade fails.
> * You can upload you backup files to amazon s3: (https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md)
> * You can skip artifacts backup by `/opt/gitlab/bin/gitlab-rake gitlab:backup:create SKIP=artifacts`
> * Also backup `/etc/gitlab/gitlab-secrets.json` to avoid issue described in (this issue)[https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1147]

### Setup 3: Restore
#### From `Gitlab data` backup:

First, we need to login the guest system:
<pre>cd {$desktop-path}/VMs/gitlab
vagrant up
vagrant ssh</pre>

Copy the backup file to GitLab's backup folder, then:
<pre>sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop sidekiq
sudo gitlab-rake gitlab:backup:restore BACKUP={$TIMESTAMP}
sudo gitlab-ctl start
sudo gitlab-rake gitlab:check SANITIZE=true</pre>

#### From `vagrant box`:
Using existing Vagrant configuration
<pre>git clone https://github.com/Carolusian/gitlab-omnibus-vagrant.git  {$desktop-path}/VMs/gitlab_restore
cd {$desktop-path}/VMs/gitlab_restore
cp config.yml.dist configy.yml
vi config.yml   # Then, input original ip addr and original hostname
vi Vagrantfile  # Then, change vm box to the backup box and comment out shell section
vagrant up
vagrant ssh
sudo gitlab-ctl restart</pre>

Everything shall works fine.

#### Restore `gitlab-secrets.json` ####

* Copy your `gitlab-secrets.json` to `/etc/gitlab/gitlab-secrets.json`
* Then run `sudo gitlab-ctl reconfigure`

### Setup 4: Upgrade
First, `vagrant ssh` to guest system.
In the guest system, download the latest version of GitLab for ubuntu 14.04.
<pre>curl -LJO "https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/gitlab-ce_x.x.x-ce.0_amd64.deb/download"</pre>

Then, start upgrading by following commands:
<pre>sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop sidekiq
sudo gitlab-ctl stop nginx
sudo dpkg -i gitlab-ce_{$VERSION}-ce.0_amd64.deb
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart</pre>

Done!

