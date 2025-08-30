class ActionType {
  final String name;
  final bool requiresData;
  String? hintValue;

  ActionType({required this.name, required this.requiresData, this.hintValue});
}

// Define your action types here
final List<ActionType> actionTypes = [
  ActionType(name: "no-action", requiresData: false),
  ActionType(name: "open-url", requiresData: true),
  ActionType(name: "fund-details", requiresData: true),
  ActionType(name: "explore-funds", requiresData: false),
  ActionType(
    name: "nft-add-edit-nominee",
    requiresData: true,
    hintValue: "Add/Edit Nominee",
  ),
  ActionType(
    name: "nft-add-bank-account",
    requiresData: true,
    hintValue: "Add Bank Account",
  ),
  ActionType(
    name: "nft-update-mobile",
    requiresData: true,
    hintValue: "Update Contact Details - Mobile Number",
  ),
  ActionType(
    name: "nft-change-bank-account",
    requiresData: true,
    hintValue: "Change Bank Account",
  ),
  ActionType(
    name: "nft-update-email-id",
    requiresData: true,
    hintValue: "Update Contact Details - Email Id",
  ),
  ActionType(
    name: "nft-register-mandate",
    requiresData: true,
    hintValue: "OTM(eNACH)",
  ),
  ActionType(
    name: "nft-update-fatca",
    requiresData: true,
    hintValue: "FATCA/CRS Declaration",
  ),
  ActionType(
    name: "nft-consolidation-of-folio",
    requiresData: true,
    hintValue: "Consolidation of Folios",
  ),
];
