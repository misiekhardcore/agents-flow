# Scope work units for /define

|Work unit type|Description|Parallelism|
|-|-|-|
|**Codebase analysis**|Analyze existing module structure, APIs, and data models|Disjoint per-module — parallelizable|
|**Prior-decision review**|Read relevant architecture decision records and wiki pages|Disjoint per-topic — parallelizable|
|**Design concern evaluation**|Assess UI/UX, data flow, security, and performance implications|Depends on codebase analysis — sequential|
