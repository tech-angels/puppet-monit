Facter.add("monit_mounts") do
        setcode do
                %x(/bin/df).split("\n").grep(/^\/dev\//).collect{|line| line.split()[5].chomp}.join(':')
        end
end
