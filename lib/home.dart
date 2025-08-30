import 'dart:convert';
import 'package:ct_campaign_create/action_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampaignCreatorPage extends StatefulWidget {
  final Map<String, dynamic>? campaignToEdit; // full campaign json
  final int? entryIndex; // index of entry inside campaign

  const CampaignCreatorPage({super.key, this.campaignToEdit, this.entryIndex});

  @override
  State<CampaignCreatorPage> createState() => _CampaignCreatorPageState();
}

class _CampaignCreatorPageState extends State<CampaignCreatorPage> {
  final List<Map<String, dynamic>> entries = [];

  final TextEditingController imageController = TextEditingController();
  final TextEditingController ctEventController = TextEditingController();
  final TextEditingController urlEventController = TextEditingController();
  final TextEditingController actionDataController = TextEditingController();
  final TextEditingController campaignNameController = TextEditingController();

  ActionType selectedActionType = actionTypes.first;

  @override
  void initState() {
    super.initState();

    if (widget.campaignToEdit != null) {
      final campaign = widget.campaignToEdit!;
      final appBanners = List<Map<String, dynamic>>.from(
        campaign['app_banners'] ?? [],
      );
      entries.addAll(appBanners);

      // if editing an existing entry
      if (widget.entryIndex != null && widget.entryIndex! < entries.length) {
        final entry = entries[widget.entryIndex!];
        imageController.text = entry["image_url"] ?? "";
        ctEventController.text = entry["ct_event"] ?? "";
        final action = entry["action"] as Map<String, dynamic>? ?? {};
        final actionTypeName = action["type"];
        selectedActionType = actionTypes.firstWhere(
          (a) => a.name == actionTypeName,
          orElse: () => actionTypes.first,
        );
        actionDataController.text = action["data"] ?? "";
        urlEventController.text = action["web_action"] ?? "";
      }
    }
  }

  void addOrUpdateEntry() {
    final action = {
      "type": selectedActionType.name,
      if (selectedActionType.requiresData &&
          actionDataController.text.isNotEmpty)
        "data": actionDataController.text,
      if (urlEventController.text.isNotEmpty)
        "web_action": urlEventController.text,
    };

    setState(() {
      if (widget.entryIndex != null && widget.entryIndex! < entries.length) {
        // Update existing entry
        entries[widget.entryIndex!] = {
          "image_url": imageController.text,
          "ct_event": ctEventController.text,
          "action": action,
        };
      } else {
        // Add new entry
        entries.add({
          "image_url": imageController.text,
          "ct_event": ctEventController.text,
          "action": action,
        });
      }

      imageController.clear();
      ctEventController.clear();
      actionDataController.clear();
      selectedActionType = actionTypes.first;
    });
  }

  void deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  Map<String, dynamic> generateCampaignJson() {
    return {"app_banners": entries};
  }

  void saveCampaign() {
    final campaignJson = generateCampaignJson();
    Navigator.pop(context, campaignJson);
  }

  void copyJsonToClipboard() {
    final campaignJson = generateCampaignJson();
    final jsonString = const JsonEncoder.withIndent("  ").convert(campaignJson);
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("JSON copied to clipboard!")));
  }

  @override
  Widget build(BuildContext context) {
    final campaignJson = generateCampaignJson();
    final jsonString = const JsonEncoder.withIndent("  ").convert(campaignJson);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Creator"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel: form + entries
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // TextField(
                      //   controller: campaignNameController,
                      //   decoration: const InputDecoration(
                      //     labelText: "Campaign Name",
                      //   ),
                      // ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: "Image URL",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      if (imageController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.network(
                            imageController.text,
                            height: 100,
                            errorBuilder:
                                (context, _, __) =>
                                    const Text("Invalid image URL"),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: ctEventController,
                        decoration: const InputDecoration(
                          labelText: "CT Event",
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ActionType>(
                        value: selectedActionType,
                        items:
                            actionTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedActionType = value!;
                            if (selectedActionType.hintValue != null) {
                              actionDataController.text =
                                  selectedActionType.hintValue!;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Action Type",
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedActionType.requiresData)
                        TextField(
                          controller: actionDataController,
                          decoration: const InputDecoration(
                            labelText: "Action Data",
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: urlEventController,
                        decoration: const InputDecoration(
                          labelText: "Web Url Action",
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: addOrUpdateEntry,
                        child: Text(
                          widget.entryIndex != null
                              ? "Update Entry"
                              : "Add Entry",
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child:
                            entries.isEmpty
                                ? const Center(
                                  child: Text("No entries yet. Add one above!"),
                                )
                                : ListView.builder(
                                  itemCount: entries.length,
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    final action =
                                        entry["action"] as Map<String, dynamic>;
                                    return Card(
                                      child: ListTile(
                                        leading: Image.network(
                                          entry["image_url"] ?? "",
                                          width: 50,
                                          errorBuilder:
                                              (context, _, __) => const Icon(
                                                Icons.broken_image,
                                              ),
                                        ),
                                        title: Text(entry["ct_event"] ?? ""),
                                        subtitle: Text(
                                          "Action: ${action["type"]}${action["data"] != null ? " → ${action["data"]}" : ""}",
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => deleteEntry(index),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: saveCampaign,
                            child: const Text("Save Campaign"),
                          ),
                          ElevatedButton(
                            onPressed: copyJsonToClipboard,
                            child: const Text("Copy JSON"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right panel: JSON preview
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(
                      jsonString,
                      style: const TextStyle(
                        fontFamily: "monospace",
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
