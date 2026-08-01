from pydantic import BaseModel 
from typing import List,Dict, Optional
from datetime import datetime 

# 1. СОСТОЯНИЕ ПЕРСОНАЖА (для RAG и логики)

class CharacterState(BaseModel): 
    character_id: str 
    world_id: str 
    current_region:str     #region_1, region_2...
    current_location:str  #loc_1_1, loc_2_2...

    # Сюжетно важные вещи 

    injures: List[str] = [] 
    inventory: List[str] = [] 
    completed_quests: List[str] = []
    active_quests: List[str] = []
    relations: Dict[str, int] = {}  # npc_id → -5..5

    updated_at: datetime = datetime.now()


# 2 ДИНАМИЧЕСКОЕ СОСТОЯНИЕ МИРА (для RAG)
class WorldState(BaseModel):
    world_id: str
    
    # Где находятся ключевые NPC (если перемещаются)
    npc_positions: Dict[str, str] = {}  # npc_id → location_id

    # Состояние важных объектов (разрушен, построен, горит)
    objects_state: Dict[str, str] = {}  # object_id → состояние

    # Репутация игрока у фракций
    player_reputation: Dict[str, int] = {}  # faction_id → -10..10
    
    updated_at: datetime = datetime.now()


class WorldEvent(BaseModel):
    id: Optional[int]
    world_id: str
    character_id: Optional[str]
    event_type: str  # "combat", "dialog", "discovery", "quest"
    summary: str     # краткое описание для RAG
    data: Dict       # полные детали
    created_at: datetime = datetime.now()