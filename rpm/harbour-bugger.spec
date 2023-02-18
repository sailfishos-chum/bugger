# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.32
# 

Name:       harbour-bugger

# >> macros
# << macros

Summary:    Bug reporting helper
Version:    0.9.9
Release:    4
Group:      Applications
License:    ASL 2.0
BuildArch:  noarch
URL:        https://github.com/sailfishos-chum/bugger
Source0:    %{name}-%{version}.tar.gz
Source100:  harbour-bugger.yaml
Source101:  harbour-bugger-rpmlintrc
Requires:   libsailfishapp-launcher
Requires:   sailfish-version >= 4.0.0
BuildRequires:  qt5-qttools-linguist
BuildRequires:  qt5-qmake
BuildRequires:  sailfish-svg2png
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
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/*/*/apps/%{name}.png
%config %{_sysconfdir}/sailjail/permissions/%{name}.profile
%config %{_sysconfdir}/firejail/%{name}.local
%dir %{_datadir}/%{name}
%{_datadir}/%{name}/translations/*.qm
%{_datadir}/%{name}/qml/*
# >> files
# << files
