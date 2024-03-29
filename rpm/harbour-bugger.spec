# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.32
# 

Name:       harbour-bugger

# >> macros
# << macros

Summary:    Bug reporting helper
Version:    0.10.5
Release:    1
Group:      Applications
License:    ASL 2.0
BuildArch:  noarch
URL:        https://github.com/sailfishos-chum/bugger
Source0:    %{name}-%{version}.tar.gz
Source100:  harbour-bugger.yaml
Source101:  harbour-bugger-rpmlintrc
Requires:   %{name}-gather-logs
Requires:   libsailfishapp-launcher
Requires:   sailfish-version >= 4.0.0
BuildRequires:  qt5-qttools-linguist
BuildRequires:  qt5-qmake
BuildRequires:  sailfish-svg2png
BuildRequires:  systemd
BuildRequires:  qml-rpm-macros
BuildRequires:  desktop-file-utils

%description
Bugger! is a little tool to assist reporting bugs on https://forum.sailfishos.org,
following a more or less standardized template.

Reporting bugs in this way should improve Jollas ability to pick them up
and track them internally.

For more information, see Help link in the description


%if "%{?vendor}" == "chum"
PackageName: Bugger!
Type: desktop-application
Categories:
 - Utility
Custom:
  Repo: https://github.com/sailfishos-chum/bugger
Icon: https://raw.githubusercontent.com/sailfishos-chum/bugger/master/icons/svgs/harbour-bugger.svg
Screenshots:
  - https://github.com/sailfishos-chum/bugger/raw/master/Screenshot_001.png
  - https://github.com/sailfishos-chum/bugger/raw/master/Screenshot_002.png
Url:
  Help: https://forum.sailfishos.org/t/10935
%endif


%package gather-logs
Summary:    Log gathering tools from %{name}
Group:      Applications
BuildArch:  noarch
Requires:   polkit
Requires(preun): systemd
Requires(post): systemd
Requires(postun): systemd

%description gather-logs
%{summary}.

%if "%{?vendor}" == "chum"
PackageName: Log collecting tools from Bugger!
Type: addon
Categories:
 - Utility
Custom:
  Repo: https://github.com/sailfishos-chum/bugger
%endif


%package gather-logs-contrib
Summary:    Log gathering contributions for %{name}
Group:      Applications
Version:    0.1
BuildArch:  noarch
Requires:   %{name}-gather-logs

%description gather-logs-contrib
%{summary}.

%if "%{?vendor}" == "chum"
PackageName: Log collecting contributions for Bugger!
Type: addon
Categories:
 - Utility
Custom:
  Repo: https://github.com/sailfishos-chum/bugger
%endif


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5 

make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# mangle version info
sed -i -e "s/unreleased/%{version}/" %{buildroot}%{_datadir}/%{name}/qml/%{name}.qml
#ghost
mkdir -p %{buildroot}/etc/systemd/journald.conf.d
touch %{buildroot}/etc/systemd/journald.conf.d/99_bugger_full_debug.conf
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%post
# >> post
%systemd_post %{name}-journalconf.service
# << post

%preun gather-logs
# >> preun gather-logs
%systemd_user_preun harbour-bugger-gather-logs.target
%systemd_user_preun harbour-bugger-gather-logs.service
#%%systemd_user_preun harbour-bugger-gather-logs-plugin@.service
%systemd_user_preun harbour-bugger-gather-logs_android.service
%systemd_user_preun harbour-bugger-gather-logs_hybris.service
%systemd_user_preun harbour-bugger-gather-logs_jolla.service
%systemd_user_preun harbour-bugger-gather-logs_update.service
# << preun gather-logs

%post gather-logs
# >> post gather-logs
%systemd_user_post harbour-bugger-gather-logs.target
%systemd_user_post harbour-bugger-gather-logs.service
#%%systemd_user_post harbour-bugger-gather-logs-plugin@.service
%systemd_user_post harbour-bugger-gather-logs_android.service
%systemd_user_post harbour-bugger-gather-logs_hybris.service
%systemd_user_post harbour-bugger-gather-logs_jolla.service
%systemd_user_post harbour-bugger-gather-logs_update.service
# << post gather-logs

%postun gather-logs
# >> postun gather-logs
%systemd_user_postun harbour-bugger-gather-logs.target
%systemd_user_postun harbour-bugger-gather-logs.service
#%%systemd_user_postun harbour-bugger-gather-logs-plugin@.service
%systemd_user_postun harbour-bugger-gather-logs_android.service
%systemd_user_postun harbour-bugger-gather-logs_hybris.service
%systemd_user_postun harbour-bugger-gather-logs_jolla.service
%systemd_user_postun harbour-bugger-gather-logs_update.service
# << postun gather-logs

%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/*/*/apps/%{name}.png
%config %{_sysconfdir}/sailjail/permissions/%{name}.profile
%config %{_sysconfdir}/firejail/%{name}.local
%dir %{_datadir}/%{name}
%{_datadir}/%{name}/translations/*.qm
%{_datadir}/%{name}/qml/*
%{_unitdir}/*.service
%{_datadir}/%{name}/99_bugger_full_debug.conf
%ghost /etc/systemd/journald.conf.d/99_bugger_full_debug.conf
# >> files
# << files

%files gather-logs
%defattr(-,root,root,-)
%dir %{_datadir}/%{name}/scripts
%{_datadir}/%{name}/scripts/README_logcollect.md
%{_userunitdir}/*.target
%{_userunitdir}/*.service
# >> files gather-logs
# << files gather-logs

%files gather-logs-contrib
%defattr(-,root,root,-)
%attr(0755,root,root) %{_datadir}/%{name}/scripts/gather-logs-*.sh
# >> files gather-logs-contrib
# << files gather-logs-contrib
