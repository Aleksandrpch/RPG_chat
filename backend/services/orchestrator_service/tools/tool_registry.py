from .tools.ach_skill import (
    ADD_ACHIEVEMENT_SCHEMA,
    tool_new_achievement,
)

from .tools.ach_skill import (
    ADD_SKILL_SCHEMA,
    tool_new_skill,
)


from .tools.search_memory import (
    SEARCH_INFO_SCHEMA,
    search_memory,
)

TOOL_SCHEMAS = [
    ADD_ACHIEVEMENT_SCHEMA,
    ADD_SKILL_SCHEMA,
    SEARCH_INFO_SCHEMA,
]

TOOL_HANDLERS = {
    func.__name__: func
    for func in (
        tool_new_achievement,
        tool_new_skill,
        search_memory,
    )
}