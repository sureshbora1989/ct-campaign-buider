import 'dart:convert';
import 'dart:html' as html; // ✅ for localStorage & clipboard in Flutter Web

import 'package:ct_campaign_create/ct_campaign.dart';
import 'package:ct_campaign_create/home.dart';
import 'package:flutter/material.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({super.key});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  final List<Campaign> campaigns = [];
  static const _storageKey = "campaigns"; // localStorage key

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  void _saveCampaigns() {
    final encoded = jsonEncode(
      campaigns.map((c) => {"name": c.name, "data": c.data}).toList(),
    );
    html.window.localStorage[_storageKey] = encoded;
  }

  void _loadCampaigns() {
    final stored = html.window.localStorage[_storageKey];
    if (stored != null) {
      final decoded = jsonDecode(stored) as List;
      setState(() {
        campaigns.clear();
        campaigns.addAll(
          decoded.map(
            (e) => Campaign(
              name: e["name"] ?? "Unnamed",
              data: Map<String, dynamic>.from(e["data"]),
            ),
          ),
        );
      });
    }
  }

  void _addCampaign(Map<String, dynamic> campaignJson) {
    setState(() {
      campaigns.add(
        Campaign(name: "Campaign ${campaigns.length + 1}", data: campaignJson),
      );
    });
    _saveCampaigns();
  }

  void _deleteCampaign(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Campaign"),
            content: const Text(
              "Are you sure you want to delete this campaign?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        campaigns.removeAt(index);
      });
      _saveCampaigns();
    }
  }

  void _openCreator() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CampaignCreatorPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      _addCampaign(result);
    }
  }

  void _copyToClipboard(Map<String, dynamic> json) {
    final text = const JsonEncoder.withIndent("  ").convert(json);
    html.window.navigator.clipboard?.writeText(text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("JSON copied to clipboard")));
  }

  void _clearAllCampaigns() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Clear All Campaigns"),
            content: const Text(
              "Are you sure you want to delete all saved campaigns? This cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete All"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        campaigns.clear();
      });
      html.window.localStorage.remove(_storageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaigns"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear All Campaigns",
            onPressed: _clearAllCampaigns,
          ),
        ],
      ),
      body:
          campaigns.isEmpty
              ? const Center(
                child: Text(
                  "No campaigns yet.\nTap + to create a campaign.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(campaign.name),
                          subtitle: Text(
                            const JsonEncoder.withIndent(
                              "  ",
                            ).convert(campaign.data),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "monospace",
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Delete Campaign",
                            onPressed: () => _deleteCampaign(index),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(campaign.name),
                                    content: SingleChildScrollView(
                                      child: Text(
                                        const JsonEncoder.withIndent(
                                          "  ",
                                        ).convert(campaign.data),
                                        style: const TextStyle(
                                          fontFamily: "monospace",
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      CampaignCreatorPage(
                                                        campaignToEdit:
                                                            campaigns[index]
                                                                .data,
                                                      ),
                                            ),
                                          ).then((updatedCampaign) {
                                            if (updatedCampaign != null) {
                                              setState(() {
                                                campaigns[index] = Campaign(
                                                  name: "Campaign ${index + 1}",
                                                  data: updatedCampaign,
                                                );
                                                _saveCampaigns();
                                              });
                                            }
                                          });
                                        },
                                        child: const Text("Edit"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                _copyToClipboard(campaign.data),
                                        child: const Text("Copy JSON"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreator,
        child: const Icon(Icons.add),
      ),
    );
  }
}
