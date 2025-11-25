# backrest

You can just edit the config/config.json file manually

- then bounce the service. It'll pick up the new config.
- open the gui in a new tab, to show the new config.

If you're controlling docker from a remote and mounting the config file from a local path, don't forget to push changes
to the local bind mount location.

---

backrest will launch backup hooks (scripts) in containers. So we have to install deps at runtime in run.sh
The containers are reused for multiple backups if backrest is not bounced.

- there is a place to define env vars for the restic command in the backrest gui, but those vars will not be available
  to the hook script that runs inside the hook's container.
- pass OP_SERVICE_ACCOUNT_TOKEN to the backrest container env, and then I believe it is inherited into the
  container environment that the backup hook (script) runs in
- 1password can then pull the github access token from the homelab account because it is running as the homelab
  service account, thanks to OP_SERVICE_ACCOUNT_TOKEN.
- If you get odd auth errors when connecting to the repo, make sure there are no newlines trailing the secrets in op.

---

backrest config file, flag on repo:
this is 100 Mb/s in KiB/s
--limit-upload 12000
this is 150 Mb/s in KiB/s
--limit-upload 18000

flag on job:
--skip-if-unchanged

hook script example:

```bash
/scripts/github/run.sh
echo {{ .ShellEscape .Summary }}
```
