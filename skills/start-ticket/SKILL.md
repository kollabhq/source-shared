---

name: start-ticket

description: Manual ticket-analysis workflow. Use when the developer explicitly starts a Jira ticket such as KDV-22. Read Jira requirements, inspect the mapped source repository, inspect Supabase when relevant, create analysis.md and checklist.md in the current ticket workspace, then stop for developer review before implementation.

---



# Start Ticket



Perform the ANALYSIS phase for the Jira ticket supplied by the developer.



The ticket key is supplied after the skill invocation, for example:



- Claude Code: `/start-ticket KDV-22`

- Codex: `$start-ticket KDV-22`



If no ticket key was supplied, ask for it and stop.



## Critical phase boundary



This skill is ANALYSIS ONLY.



During this skill:



- Do not create or switch Git branches.

- Do not modify application source code.

- Do not modify the target repository.

- Do not run database migrations.

- Do not modify database schema or data.

- Do not update Jira.

- Do not change Jira status.

- Do not comment on Jira.

- Do not commit or push anything.

- Do not stash, reset, discard, or overwrite developer changes.

- Do not install or update dependencies.



Repository inspection, Jira reads, Supabase reads, and writing analysis artifacts into the current ticket workspace are allowed.



At the end of the workflow, STOP and wait for developer review.



## Configuration



Read the installed supporting configuration:



- `references/projects.yaml`

- `references/developer.local.yaml`



Use `projects.yaml` to map the Jira project key to a repository.



Use `developer.local.yaml` for:



- developer name

- branch prefix

- ticket-analysis root

- local repository path

- Jira MCP server name

- Supabase MCP server name



Never print authentication tokens or secrets.



## 1. Validate the ticket workspace



Treat the current working directory as the ticket workspace.



The developer is expected to invoke this skill from a folder such as:



`D:\ticket-analysis\KDV-22-team-roles-permissions`



Validate that:



1. The current directory is under the configured `ticket_analysis_root`.

2. The current directory is NOT the ticket-analysis root itself.

3. The current directory name contains the supplied ticket key.



If validation fails, stop and explain what needs to be corrected.



Do not automatically create a ticket folder somewhere else.



All generated analysis artifacts must be written into the current working directory.



## 2. Check for an existing Jira snapshot



Look for:



`context/jira.md`



If it already exists:



- use the existing snapshot by default

- do not call Jira again merely to repeat information already captured

- mention that cached Jira context is being used



Only refresh Jira when the developer explicitly asks for a refresh.



If no Jira snapshot exists, continue to Jira retrieval.



## 3. Read the Jira ticket



Use the configured Atlassian/Jira MCP.



This is READ ONLY.



Retrieve the supplied ticket and gather, where available:



- ticket key

- summary/title

- current status

- priority

- issue type

- parent ticket

- description

- user story

- acceptance criteria

- assignee

- components

- labels

- subtasks

- linked issues

- relevant comments

- relevant attachment metadata



Avoid repeated Jira lookups for information already returned.



If Jira cannot be accessed or the ticket cannot be found:



- record the failure in `checklist.md`

- stop

- do not guess the requirements



Create:



`context/jira.md`



Capture the Jira information there as a factual snapshot.



Clearly record when the snapshot was retrieved.



Do not mix implementation assumptions into the Jira snapshot.



## 4. Resolve the target repository



Extract the Jira project prefix from the ticket key.



Example:



`KDV-22` -> `KDV`



Use `references/projects.yaml` to determine the configured repository.



Then use `references/developer.local.yaml` to determine the local repository path.



For example:



`KDV -> kollab -> D:\kollab`



If no mapping exists:



- add an Open Question

- stop before implementation-related analysis that depends on the repository

- never guess a repository path



## 5. Validate and inspect the repository



The target repository is READ ONLY during this skill.



Verify:



- the path exists

- it is a Git repository

- its Git remote

- current branch

- current commit

- working-tree status



Do not:



- checkout

- switch

- pull

- merge

- reset

- stash

- commit

- push

- create a branch



If the repository contains uncommitted changes, do not alter them.



Record the condition in the analysis.



Inspect the source code necessary to understand the ticket.



Search for:



- existing implementations related to the ticket

- relevant frontend components

- relevant backend/server code

- API routes or server actions

- types/interfaces

- authentication and authorization logic

- database migrations

- tests

- existing utilities/helpers



Do not assume a file must change merely because its name looks relevant.



Read enough implementation detail to explain WHY each proposed file is relevant.



Create:



`context/repository.md`



Record:



- repository name

- repository path

- remote

- branch inspected

- commit inspected

- working-tree state

- relevant files

- relevant existing behaviour



## 6. Decide whether Supabase analysis is required



Use Supabase MCP when the ticket may affect:



- persisted application data

- tables

- columns

- relationships

- constraints

- authentication

- authorization

- team membership

- roles

- permissions

- RLS

- database functions

- triggers

- migrations

- storage

- server-side database enforcement



If Supabase is not relevant, explicitly state:



`Supabase inspection required: No`



Do not call Supabase merely because the MCP exists.



If Supabase is relevant, use the configured Supabase MCP in READ-ONLY mode.



Allowed examples:



- list schemas/tables

- inspect table definitions

- inspect columns

- inspect relationships

- inspect RLS policies

- inspect functions

- run SELECT-only SQL queries needed for analysis



Never:



- INSERT

- UPDATE

- DELETE

- ALTER

- DROP

- CREATE

- TRUNCATE

- execute migration SQL

- apply migrations

- change RLS

- modify database functions

- modify database data



Create:



`context/database.md`



Record the relevant database state and why it matters to the ticket.



## 7. Compare requirement versus current implementation



Treat the sources differently:



Jira describes WHAT SHOULD HAPPEN.



The repository describes WHAT THE APPLICATION CURRENTLY DOES.



Supabase describes WHAT THE DATABASE CURRENTLY DOES.



Compare these sources.



Identify:



- existing behaviour that already satisfies the ticket

- missing behaviour

- behaviour that needs modification

- potential security implications

- database implications

- frontend implications

- backend implications

- testing implications

- migration requirements



Do not invent requirements that are not supported by Jira.



If an implementation decision cannot safely be inferred, create an Open Question.



## 8. Produce analysis.md



Use `assets/analysis-template.md` as the structure.



Create or update:



`analysis.md`



The analysis must include:



- Ticket Metadata

- Requirement Summary

- User Story

- Acceptance Criteria

- Current System Analysis

- Repository Analysis

- Database / Supabase Analysis

- Requirement Gap Analysis

- Proposed Implementation

- Expected File Changes

- Database Changes

- Security / RLS Considerations

- Testing Considerations

- Risks

- Open Questions

- Implementation Gate



For Expected File Changes, explain WHY each file is expected to change.



Separate:



- files likely to be modified

- files that may need to be created

- files inspected but probably do not need changes



Do not claim a file definitely needs modification when evidence is uncertain.



## 9. Open Questions



Create questions only for genuine ambiguity.



Each question must contain:



- the uncertainty

- why it matters

- the relevant evidence from Jira/code/database

- a place for the developer's answer



Format:



### Q1 — Question title



**Why this needs clarification**



Explanation.



**Developer answer**



> [Waiting for developer]



Do not answer product or architectural questions on behalf of the developer when the available evidence is insufficient.



## 10. Produce checklist.md



Use `assets/checklist-template.md`.



Create or update:



`checklist.md`



The checklist must reflect what ACTUALLY happened.



Do not mark a step complete unless it was performed successfully.



At the end of a successful start-ticket analysis:



`Current Phase: ANALYSIS`



`Current Step: Waiting for developer review`



The implementation section must remain unchecked.



## 11. Final gate



After analysis is complete:



STOP.



Do not begin implementation even when the solution appears obvious.



Tell the developer:



- where `analysis.md` was created

- where `checklist.md` was created

- which repository was identified

- whether Supabase was inspected

- how many Open Questions remain

- that no source code, database state, Git branches, or Jira state were modified



The developer must review and answer the Open Questions before implementation begins.

