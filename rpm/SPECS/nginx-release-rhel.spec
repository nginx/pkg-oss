%define os_variant rhel

Name:		nginx-release-%{os_variant}
Version:	%{rhel}
Release:	0%{?dist}.ngx
Summary:	nginx repo configuration and pgp public keys

Group:		System Environment/Base
License:	BSD
URL:		http://nginx.org
Source0:	nginx.repo
Source1:	RPM-GPG-KEY-nginx
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Provides:       nginx-release

BuildArch:	noarch

%description
yum config files for nginx repository, and nginx public signing key.
After the package installation you will be able to import the key
to rpm with the "rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-nginx"
command, and turn on option gpgcheck in /etc/yum.repos.d/nginx.repo

%install
%{__rm} -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
%{__mkdir} -p $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg
%{__install} -m 644 -p %{SOURCE0} $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/
%{__sed} -i "s/OS/%{os_variant}/" $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/nginx.repo
%{__sed} -i "s/RELEASEVER/%{rhel}/" $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/nginx.repo
%{__install} -m 644 -p %{SOURCE1} $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root)
%config(noreplace) %{_sysconfdir}/yum.repos.d/nginx.repo
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-nginx

%changelog
* Fri Oct 14 2011 Sergey Budnevitch <sb@nginx.com>
- Initial release
