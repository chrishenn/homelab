# pulumi python

- A Pulumi "project" is always 1:1 with a pulumi "program".
- A Pulumi "project" is always 1:1 with a pulumi "backend".
- A pulumi "project" defines a "program" that is restricted to a single pulumi language (js/ts, python, go).
- The "program" is a single file (js/ts, python, go) that creates instances of pulumi resource types when run.
- Those resource instances declare the desired state when a pulumi command creates them.

You can modify the pulumi "config" passed to your "project's" single "program", by declaring multiple pulumi "stacks"
in your "project".

- The global "project" config is read from `Pulumi.yaml`
- The individual "stack" configs are read from `Pulumi.<stackname>.yaml`

---

Stacks and projects within an "org" can communicate to each other:

- "stacks" within "projects" within a single pulumi "org" can communicate with each other via stack "outputs"
- Any "stack" within any "project" can read "stack outputs" from any other stack in any other project

A stack output is a value that is exported at the end of a successful update, usually intended for use outside of the
Pulumi program context: either from the command line via the pulumi stack output command or in another Pulumi program by
using a stack reference.

- Stack outputs are findable via the stacks FQ-name, eg: "org_name/project_name/stack_name"

```python
# using the pulumi StackReference type and fully-qualified stack name "corpname/infra/other_stack"
otherstack = StackReference("corpname/infra/other_stack")
other_output = otherstack.get_output("x")
```

---

Pulumi "resources" are declared using various resource types, imported from the relevant pulumi SDK in your pulumi
program.

Dependencies between resources are declared by specifying "resource inputs" and "outputs". The pulumi state solver makes
sure that the dependency graph is set up correctly, and that work is done in parallel when possible.

---

Pulumi stores "state" of a stack in a "state file", which is stored somewhere - in pulumi cloud by default. You can also
host your own backend, including: the local filesystem; an S3 bucket; azure blob store; GC storage; or a postgres db.

For DIY backend, the orgName portion of the stack name must always be the constant value `organization`.

---

The default org was set to one with "enterprise trial expired" warnings all over it, so set the default org to my
personal pulumi account instead

```bash
pulumi org set-default cp1000

# project name: iac_python
pulumi new

# new stack: local_dns
pulumi stack init local_dns

# activate the stack
pulumi stack select local_dns

# update the stack state
# top-level commands default to the "active" or "selected" stack, but can be overridden with the -s flag
pulumi up -s local_dns
```
