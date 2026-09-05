---

name: implement-ticket

description: Implement an analysed Jira ticket after developer review. Validate the completed ticket analysis, verify the mapped repository is safe, create the developer ticket branch from the latest origin/main, stop for branch confirmation, then implement only the approved plan and update checklist.md.

---



# Implement Ticket



Implement a Jira ticket that has already completed the `start-ticket` analysis workflow.



Example invocations:



- Claude Code: `/implement-ticket KDV-22`

- Codex: `$implement-ticket KDV-22`



If no ticket key is supplied, ask for it and stop.



## Critical rules



This skill may modify the mapped application repository, but only after all safety gates below have passed.



Never:



- guess unresolved product requirements

- ignore unanswered Open Questions

- discard developer changes

- reset developer work

- automatically stash developer work

- force checkout a branch

- force push

- commit unless the developer explicitly asks

- push unless the developer explicitly asks

- create a pull request unless the developer explicitly asks

- modify Jira unless the developer explicitly asks

- change Jira status automatically

- apply Supabase migrations directly unless the developer explicitly approves that action



Database schema changes should normally be created as version-controlled migration files in the application repository.



## Configuration



Read:



- `references/projects.yaml`

- `references/developer.local.yaml`



Use them to resolve:



- developer name

- branch prefix

- ticket analysis root

- ticket project mapping

- repository path

- default branch

- Jira MCP name

- Supabase MCP name



Branch naming MUST use the configured format.



For example:



`Shane + KDV-22 -> shane/KDV-22`



Do not invent prefixes such as:



- `feature/`

- `newfeature/`

- `bugfix/`



unless the shared configuration explicitly says to use them.



## 1. Validate the ticket workspace



Treat the current working directory as the ticket workspace.



Validate:



1. It is inside the configured ticket-analysis root.

2. It is not the ticket-analysis root itself.

3. Its folder name contains the supplied ticket key.

4. `analysis.md` exists.

5. `checklist.md` exists.



If any validation fails, stop.



Do not automatically create another workspace.



## 2. Validate analysis readiness



Read `analysis.md`.



Confirm:



- the ticket key matches the supplied ticket

- the repository was identified

- Jira requirements were analysed

- repository analysis was completed

- database analysis was completed or explicitly marked not required

- Open Questions are resolved

- the Implementation Gate exists



Search for unresolved markers such as:



- `[Waiting for developer]`

- `TODO developer`

- unresolved Open Questions

- ambiguous implementation decisions explicitly marked as requiring developer input



If any unresolved question remains:



STOP.



Tell the developer which questions must be resolved.



Do not create a branch.



## 3. Validate checklist state



Read `checklist.md`.



Before implementation, expect the analysis phase to show:



- Developer reviewed analysis.md

- Open Questions answered

- Developer confirmed implementation approach



These must be complete.



The invocation of `$implement-ticket <ticket>` or `/implement-ticket <ticket>` counts as explicit developer approval to begin the implementation workflow.



Update:



`Developer approved implementation`



to complete only after the analysis checks above succeed.



Do not begin source changes yet.



## 4. Resolve repository and branch



Extract the Jira project prefix.



Use shared configuration to resolve:



- repository name

- local path

- default branch

- developer branch prefix



Determine the branch name using the configured format.



Example:



`shane/KDV-22`



Record the expected branch in `checklist.md`.



Never derive branch naming from existing branch conventions unless shared configuration instructs you to do so.



## 5. Safety-check the repository



Before changing anything, verify:



- repository path exists

- path is a Git repository

- remote matches the configured repository

- current working tree status

- current branch

- default remote branch exists



Run read-only Git inspection first.



If the working tree has:



- modified files

- staged files

- untracked files



STOP.



Do not stash them.



Do not discard them.



Tell the developer to commit, stash, move, or discard their work manually.



## 6. Refresh remote state



If the working tree is clean:



Run:



`git fetch origin`



Do NOT run:



`git pull`



The implementation branch should be based directly on the current remote default branch.



Verify:



`origin/<default_branch>`



exists.



Example:



`origin/main`



## 7. Check whether the ticket branch already exists



Check both:



- local branches

- origin remote branches



If the intended ticket branch already exists:



STOP.



Report where it exists and ask the developer how they want to proceed.



Do not silently reuse, overwrite, delete, or recreate an existing branch.



## 8. Create the implementation branch



Create the branch directly from the latest remote default branch.



Example:



`git switch -c shane/KDV-22 origin/main`



Immediately verify:



- current branch name

- HEAD commit

- working tree remains clean



Update `checklist.md`:



- Developer approved implementation = complete

- Repository working tree confirmed safe for implementation = complete

- Latest remote state checked = complete

- Implementation branch created = complete

- Branch name confirmed = NOT YET complete



Set:



`Current Phase: IMPLEMENTATION`



`Current Step: Waiting for branch confirmation`



## 9. Branch confirmation gate



STOP after creating the branch.



Tell the developer:



- repository path

- base branch

- new branch

- HEAD commit

- working-tree status

- that no application changes have been made yet



Ask the developer to confirm the branch before implementation begins.



Do not modify application source code until the developer explicitly confirms.



A reply such as:



- `Proceed`

- `Branch confirmed`

- `Continue implementation`



counts as confirmation.



After confirmation:



- mark `Branch name confirmed` complete

- set `Current Step: Implementing approved plan`



## 10. Re-read the approved plan



Before editing code, re-read:



- `analysis.md`

- `context/repository.md`

- `context/database.md` when present



Treat Developer Answers as authoritative for resolved decisions.



Implement only work that is:



- REQUIRED by Jira

- directly necessary to satisfy the approved implementation plan

- explicitly approved by Developer Answers



Do not silently add unrelated refactors or product features.



Recommendations that are not required should remain unimplemented unless the developer explicitly approved them.



## 11. Repository changes



Make changes only inside the mapped target repository unless the approved plan explicitly requires another mapped repository.



Keep changes focused on the ticket.



When changing authorization:



- enforce security server-side/database-side

- do not rely only on hidden UI controls

- preserve existing tenant/brand isolation

- preserve platform-admin versus brand-role distinctions



When existing code conflicts with the approved analysis, stop and explain the conflict instead of guessing.



## 12. Supabase implementation



If database changes are required:



Prefer creating a new migration under the repository's normal migration directory.



For Kollab, this is expected to be:



`supabase/migrations/`



Do not rewrite historical migrations unless the analysis explicitly establishes that this is required.



Do not automatically apply the new migration to Supabase.



Using Supabase MCP during implementation is allowed for READ-ONLY verification.



Examples:



- inspect current schema

- inspect RLS

- inspect functions

- inspect table definitions



Do not use Supabase MCP to mutate schema or data unless the developer explicitly gives approval for that specific action.



## 13. Keep checklist.md current



Update `checklist.md` as work progresses.



Mark a task complete only when it actually succeeds.



Examples:



- Code implementation started

- Database migration created if required

- Tests added or updated

- Tests passed

- Lint/type checks passed



If a step is not applicable, annotate it as:



`N/A — <reason>`



rather than falsely marking work as performed.



## 14. Validation



Use repository-appropriate validation.



Inspect package scripts/configuration before choosing commands.



Where available, run relevant:



- tests

- lint

- type checks

- build checks



Do not invent commands that the repository does not support.



If validation fails:



- record the failure

- attempt fixes only when they are within ticket scope

- do not hide failures

- report remaining failures clearly



## 15. Review the final diff



Before completing implementation:



Inspect:



- `git status`

- `git diff`

- changed files



Compare the result against `analysis.md`.



Confirm:



- no unrelated files changed

- no accidental secrets were introduced

- no generated files were modified unnecessarily

- required migration/type updates are present where applicable



Do not commit.



Do not push.



## 16. Finish implementation phase



Update:



`Current Phase: IMPLEMENTATION COMPLETE`



`Current Step: Waiting for developer review`



Mark only tasks that were actually completed.



Keep these completion steps unchecked until the developer performs/reviews them:



- Developer reviewed implementation

- Ready for commit / pull request



Tell the developer:



- branch name

- files changed

- migration files created

- tests/checks run

- whether they passed

- any remaining risks or blockers



STOP.



Wait for developer review.



Do not commit, push, create a PR, or update Jira unless explicitly requested.

