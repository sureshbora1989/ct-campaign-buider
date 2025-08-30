class ActionType {
  final String name;
  final bool requiresData;

  ActionType({required this.name, required this.requiresData});
}

// Define your action types here
final List<ActionType> actionTypes = [
  ActionType(name: "no-action", requiresData: false),
  ActionType(name: "open-url", requiresData: true),
  ActionType(name: "fund-details", requiresData: true),
  ActionType(name: "explore-funds", requiresData: false),
  ActionType(name: "nft-add-edit-nominee", requiresData: true),
  ActionType(name: "nft-add-bank-account", requiresData: true),
  ActionType(name: "nft-update-mobile", requiresData: true),
  ActionType(name: "nft-change-bank-account", requiresData: true),
  ActionType(name: "nft-update-email-id", requiresData: true),
  ActionType(name: "nft-register-mandate", requiresData: true),
  ActionType(name: "nft-update-fatca", requiresData: true),
  ActionType(name: "nft-consolidation-of-folio", requiresData: true),
];
