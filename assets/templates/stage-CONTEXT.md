<!-- Format credit: icm-architect (RinDig) / the ICM paper. Section-compatible
     with icm-architect's stage-CONTEXT.md — same four headings, so workspaces
     built there lint clean here. Intentional deltas: {{}} placeholders; the
     per-stage references/ input line dropped (add it back when a stage grows
     local reference material). -->
# {{NN}}_{{stage-name}} — {{the job in five words}}

One job: {{the single thing this stage does}}.

## Inputs
- Working (this run): ../{{NN-1}}_{{prev-stage}}/output/{{file}}
- Reference (every run): ../../_shared/{{rules-file}}.md

Do NOT load: {{what an eager agent would wrongly pull in — other stages'
references, prior runs, the whole _shared folder}}.

## Process
1. {{Read the inputs.}}
2. {{Transform, following the reference constraints.}}
3. {{Hard limits worth restating: length, count, format.}}

## Outputs
- {{artifact}}.md → output/

## Human check
{{One concrete act: read it aloud / verify the numbers against X / confirm the
order survived. Edit the output in place — the next stage reads whatever is
here.}}
