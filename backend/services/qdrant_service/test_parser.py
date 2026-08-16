from state_parser import parse_state 

state = {
  "character_location": {
    "value": "loc_1_1",
    "description": "Текущее местоположение главного героя"
  },
  "npc_states": {
    "npc_1": {
      "location": {
        "value": "loc_1_1",
        "description": "Текущее местоположение NPC Странник"
      },
      "status": {
        "value": "alive_and_available",
        "description": "Текущее состояние NPC Странник"
      }
    },
    "npc_2": {
      "location": {
        "value": "loc_2_1",
        "description": "Текущее местоположение NPC Торговец"
      },
      "status": {
        "value": "alive_and_available",
        "description": "Текущее состояние NPC Торговец"
      }
    },
    "npc_3": {
      "location": {
        "value": "loc_3_1",
        "description": "Текущее местоположение NPC Служитель"
      },
      "status": {
        "value": "alive_and_available",
        "description": "Текущее состояние NPC Служитель"
      }
    }
  },
  "object_states": {
    "loc_1_1_statue": {
      "status": {
        "value": "dormant",
        "description": "Состояние статуи забытого бога в руинах храма"
      }
    },
    "loc_3_1_runes": {
      "status": {
        "value": "unreadable",
        "description": "Состояние древних рун на алтаре святилища"
      }
    }
  },
  "faction_reputation": {
    "faction_1": {
      "reputation": {
        "value": 0,
        "description": "Текущая репутация героя у фракции Хранители леса"
      }
    },
    "faction_2": {
      "reputation": {
        "value": 0,
        "description": "Текущая репутация героя у фракции Путники"
      }
    },
    "faction_3": {
      "reputation": {
        "value": 0,
        "description": "Текущая репутация героя у фракции Служители святилища"
      }
    }
  }
}

docs=parse_state(state,chat_id='test-chat')
for doc in docs: 
    print(doc)
'''{'text': 'Текущее местоположение главного героя: loc_1_1', 'payload': {'chat_id': 'test-chat', 'path': 'character_location', 'value': 'loc_1_1', 'description': 'Текущее местоположение главного героя'}}
{'text': 'Текущее местоположение NPC Странник: loc_1_1', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_1.location', 'value': 'loc_1_1', 'description': 'Текущее местоположение NPC Странник'}}
{'text': 'Текущее состояние NPC Странник: alive_and_available', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_1.status', 'value': 'alive_and_available', 'description': 'Текущее состояние NPC Странник'}}
{'text': 'Текущее местоположение NPC Торговец: loc_2_1', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_2.location', 'value': 'loc_2_1', 'description': 'Текущее местоположение NPC Торговец'}}
{'text': 'Текущее состояние NPC Торговец: alive_and_available', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_2.status', 'value': 'alive_and_available', 'description': 'Текущее состояние NPC Торговец'}}
{'text': 'Текущее местоположение NPC Служитель: loc_3_1', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_3.location', 'value': 'loc_3_1', 'description': 'Текущее местоположение NPC Служитель'}}
{'text': 'Текущее состояние NPC Служитель: alive_and_available', 'payload': {'chat_id': 'test-chat', 'path': 'npc_states.npc_3.status', 'value': 'alive_and_available', 'description': 'Текущее состояние NPC Служитель'}}
{'text': 'Состояние статуи забытого бога в руинах храма: dormant', 'payload': {'chat_id': 'test-chat', 'path': 'object_states.loc_1_1_statue.status', 'value': 'dormant', 'description': 'Состояние статуи забытого бога в руинах храма'}}
{'text': 'Состояние древних рун на алтаре святилища: unreadable', 'payload': {'chat_id': 'test-chat', 'path': 'object_states.loc_3_1_runes.status', 'value': 'unreadable', 'description': 'Состояние древних рун на алтаре святилища'}}
{'text': 'Текущая репутация героя у фракции Хранители леса: 0', 'payload': {'chat_id': 'test-chat', 'path': 'faction_reputation.faction_1.reputation', 'value': 0, 'description': 'Текущая репутация героя у фракции Хранители леса'}}
{'text': 'Текущая репутация героя у фракции П тники: 0', 'payload': {'chat_id': 'test-chat', 'path': 'faction_reputation.faction_2.reputation', 'value': 0, 'description': 'Текущая репутация героя у фракции Путники'}}
{'text': 'Текущая репутация героя у фракции Служители святилища: 0', 'payload': {'chat_id': 'test-chat', 'path': 'faction_reputation.faction_3.reputation', 'value': 0, 'description': 'Текущая репутация героя у фракции Служители святилища'}}'''