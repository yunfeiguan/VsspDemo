%define name xtao-tools
%define version 1.0.0
%define release 1

Name:           %{name}
Version:        %{version}	
Release:	%{release}
Summary:        Install ceph-fuse command for Xtao Storage System	

Group:		Development/Libraries
License:        GPL	
#URL:		
Source0:        %{name}.tar.gz	
#BuildRoot:      %{_tmppath}/%{name}-root
BuildRoot:      $RPM_BUILD_ROOT

#BuildRequires:	
#Requires:	

%description
UNKNOWN


%prep
#%setup -q
%setup -c -n %{name}


%install
#make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/%{_sbindir}
cp -f %{name}/mount.annafs %{buildroot}/usr/sbin
cp -f %{name}/xtanna %{buildroot}/usr/sbin


%clean
rm -rf $RPM_BUILD_ROOT 

%files
%defattr(-,root,root)
/usr/sbin/mount.annafs
/usr/sbin/xtanna


# before rpm uninstall 
%preun
rm -rf %{buildroot}/usr/sbin/mount.annafs
rm -rf %{buildroot}/usr/sbin/xtanna
