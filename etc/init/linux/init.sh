#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

install_yum_package() {
  e_header "install yum packages"
  sudo yum install -y gcc tmux zsh vim go telnet tree ctags
  e_success "install yum packages"
}

change_locale_to_jp() {
  e_header "change locale to ja_JP.UTF-8"

  sudo yum -y install ibus-kkc vlgothic-*
  sudo localectl set-locale LANG=ja_JP.UTF-8
}

install_yum_repositories() {
  e_header "adding yum repositories"

  # yumのpriorityツール
  sudo yum -y install yum-plugin-priorities

  # CentOS Base priority=1
  sudo sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

  # fedora EPEL priority=5
  sudo yum -y install epel-release
  sudo sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo

  # RPM Forge   priority=10
  sudo yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
  sudo sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/rpmforge.repo

  e_done "adding yum repositories"
}

yum_cron_security() {
  e_newline
  e_header "install yum-cron-security"
  sudo yum install yum-cron-security -y

  sudo service yum-cron start
  sudo chkconfig yum-cron on

  status=`chkconfig --list yum-cron | cut -f5 | cut -d':' -f2`
  if [ "$status" = "on" ]; then
    e_success "checkconfig yum-cron on"
  else
    e_error "checkconfig yum-cron on"
  fi

  e_done "intall yum-cron-security"
}

dist=`get_dist`
if [ "$dist" = "CentOS" ]; then
  install_yum_package
  install_yum_repositories
  change_locale_to_jp
elif [ "$dist" = "Amazon" ]; then
  install_yum_package
  install_yum_repositories
  yum_cron_security
  change_locale_to_jp
else
  e_error "unsupported distribution. install common settings only."
fi
