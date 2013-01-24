exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

package{ "git": ensure => installed }
package{ "liblua5.1-0-dev": ensure => installed }
package{ "lua5.2": ensure => installed }
package{ "luarocks": ensure => installed }

exec { "lua-fix":
  cwd => "/tmp",
  command => "/usr/bin/[ -e  /usr/local/share/lua/5.1/strict.lua ] || ( /bin/mkdir -p /usr/local/share/lua/5.1 && wget http://www.lua.org/ftp/lua-5.1.4.tar.gz && tar xzvf lua-5.1.4.tar.gz && cp `find . -name strict.lua` /usr/local/share/lua/5.1/ )"
}
