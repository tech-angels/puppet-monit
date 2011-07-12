Facter.add("monit_mounts") do
  setcode do
    %x(cat /proc/mounts).split("\n").grep(/^\/dev\//).collect{|line| line.split()[1].chomp}.join(':')                
  end
end
