# Scope work units

|Work unit type|Description|Parallelism|
|-|-|-|
|**Domain research**|Codebase scan for architecture patterns, data models, API contracts relevant to one domain|Disjoint per-domain — parallelizable|
|**Flow analysis** (high-risk only)|Control flow, error path, and failure mode mapping for high-risk domains|Depends on domain-researcher output — sequential per domain|
