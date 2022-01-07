# These commands will only work when Craft is installed, which means the first deploy will fail!
if /usr/bin/env php /workspace/craft install/check
then
    /usr/bin/env php /workspace/craft up
fi
