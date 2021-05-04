# These commands will only work when Craft is installed, which means the first deploy will fail!
if /usr/bin/env php /workspace/craft install/check
then
    /usr/bin/env php /workspace/craft migrate/all --interactive=0
    /usr/bin/env php /workspace/craft project-config/apply --interactive=0
    /usr/bin/env php /workspace/craft cache/flush-schema db --interactive=0
fi