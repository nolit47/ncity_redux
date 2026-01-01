local MODE = MODE

MODE.TeamVariables = {
    [1] = {
        Tickets = 10
    },
    [2] = {
        Tickets = 10
    }
}

MODE.Phases = {
    [0] = "",
    [1] = "Фаза исследования",
    [2] = "Фаза атаки/улучшения"
}

MODE.Buildings = {
    HQ = "Штаб",
    LAB = "Лаборатория",
    REC = "Центр вербовки",
    FRT = "Форт",
    DRG = "Нарколаборатория"
}

MODE.MapSlots = {
    [1] = {
        [1] = {
            map = "gm_construct",
            captured = 0,
            building = "HQ"
        }
    },
    [2] = {
        [1] = {
            map = "gm_construct"
        }
    },
    [3] = {
        [1] = {
            map = "gm_construct"
        },
        [2] = {
            map = "gm_construct"
        }
    },
    [4] = {
        [1] = {
            map = "gm_construct"
        },
        [2] = {
            map = "ttt_metropolis"
        },
        [3] = {
            map = "gm_construct"
        }
    },
    [5] = {
        [1] = {
            map = "gm_construct"
        },
        [2] = {
            map = "gm_construct"
        },
    },
    [6] = {
        [1] = {
            map = "gm_construct"
        },
    },
    [7] = {
        [1] = {
            map = "gm_construct",
            captured = 1,
            building = "HQ"
        },
    },
}

MODE.Research = {
    ["armor"] = {
        shortname = "A",
        [1] = {
            name = "Броня T1",
            points = 3
        },
        [2] = {
            name = "Броня T2",
            points = 5
        },
        [3] = {
            name = "Броня T3",
            points = 10
        }
    },
    ["guns"] = {
        shortname = "G",
        [1] = {
            name = "Оружие T1",
            points = 3
        },
        [2] = {
            name = "Оружие T2",
            points = 5
        },
        [3] = {
            name = "Оружие T3",
            points = 10
        }
    },
    ["buldings"] = {
        shortname = "B",
        [1] = {
            name = "Постройки T2",
            points = 5
        },
        [2] = {
            name = "Постройки T3",
            points = 10
        }
    },
}

MODE.Teams = {
    [0] = {
        Research = {}
    },
    [1] = {
        Research = {}
    }
}

MODE.ResearchVotes = table.Copy(MODE.Research)
MODE.ResearchPlayerVotes = {}

function MODE:ResetValues()
    MODE.ResearchVotes = table.Copy(MODE.Research)
    MODE.ResearchPlayerVotes = {}
    MODE.Teams = {
        [0] = {
            research = {}
        },
        [1] = {
            research = {}
        }
    }
end