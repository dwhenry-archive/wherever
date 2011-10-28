Feature: I can add and retrieve data fro the system

  Scenario: I add data to the system
    Given a configured wherever system with keys "fund_id"
    When I add data to the system for:
    """
    {
      "keys": {"fund_id": 1},
      "unique": {"id": 1, "version": 1},
      "position": 100,
      "settled": true
    }
    """
    Then I have have the following data:
      | table  | keys                                        | settled positon | unsettled position |
      | keys   | {"fund_id": 1}                              | 100             | 0                  |
      | unique | {"fund_id": 1, "trade_id": 1}               | 100             | 0                  |
      | all    | {"fund_id": 1, "trade_id": 1, "version": 1} | 100             | 0                  |
