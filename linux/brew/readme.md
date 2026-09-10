# brew

I copied gh workflow files to adapt https://github.com/ublue-os/homebrew-tap into the cask tap format that mise bootstrap
will consume - this script + action adds cask metadata in json form to repo/api/<token>.json. By golly I truly hate
github actions (nevermind me).

However, mise bootstrap won't consume these tapped casks, since mise boostrap on linux doesn't support casks with
postflight_steps or preflight_steps.

By the way, the homebrew cask format specifies a ruby file with instructions on installing a package. Hilariously, the
ruby api in these preflight_steps is all the same damn things we've been bash-scripting since the pyramids - mkdir,
render a .desktop file, set file permissions, copy files and icons into root-owned directories...surely state management
for package artifacts is not this difficult? No linux package manager can ship a package format that does this efficiently?
