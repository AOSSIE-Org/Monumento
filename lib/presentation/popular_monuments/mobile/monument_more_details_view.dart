import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/wiki_data_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class Section {
  final String title;
  final String content;

  Section({required this.title, required this.content});
}

class MonumentDetailedPage extends StatefulWidget {
  final WikiDataEntity wikiData;
  final String monumentName;

  const MonumentDetailedPage({
    Key? key,
    required this.wikiData,
    required this.monumentName,
  }) : super(key: key);

  @override
  State<MonumentDetailedPage> createState() => _MonumentDetailedPageState();
}

class _MonumentDetailedPageState extends State<MonumentDetailedPage> {
  late List<Section> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _parseContentIntoSections(widget.wikiData.extract);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appWhite,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appBlack,
          ),
        ),
        title: Text(
          widget.monumentName,
          style: AppTextStyles.s16(
            color: AppColor.appBlack,
            fontType: FontType.MEDIUM,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final url = 'https://en.wikipedia.org/wiki?curid=${widget.wikiData.pageId}';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Could not open Wikipedia page"),
                    ),
                  );
                }
              }
            },
            icon: const Icon(
              Icons.open_in_new,
              color: AppColor.appPrimary,
            ),
            tooltip: "View on Wikipedia",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.wikiData.title,
                            style: AppTextStyles.s20(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColor.appPrimary.withAlpha((255 * 0.1).round()),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Wikipedia",
                            style: AppTextStyles.s12(
                              color: AppColor.appPrimary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.wikiData.description,
                      style: AppTextStyles.s14(
                        color: AppColor.appBlack,
                        fontType: FontType.REGULAR,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_sections.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.wikiData.extract,
                    style: AppTextStyles.s14(
                      color: AppColor.appBlack,
                      fontType: FontType.REGULAR,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < _sections.length; i++)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        collapsedBackgroundColor: AppColor.appWhite,
                        backgroundColor: AppColor.appWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          _sections[i].title,
                          style: AppTextStyles.s16(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _sections[i].content,
                              style: AppTextStyles.s14(
                                color: AppColor.appBlack,
                                fontType: FontType.REGULAR,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  List<Section> _parseContentIntoSections(String extract) {
    List<Section> sections = [];
    final paragraphs = extract.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    
    if (paragraphs.length <= 1) {
      final potentialSections = _identifySectionsByKeywords(extract);
      if (potentialSections.isNotEmpty) {
        return _deduplicateSections(potentialSections);
      }
      if (extract.trim().isNotEmpty) {
        sections.add(Section(title: "About this Monument", content: extract.trim()));
      }
      return sections;
    }
    bool isFirstParagraph = true;
    String currentSection = "About this Monument";
    String currentContent = "";
    
    for (var paragraph in paragraphs) {
      if (paragraph.length < 50 && !paragraph.contains('. ')) {
        if (currentContent.isNotEmpty) {
          sections.add(Section(title: currentSection, content: currentContent.trim()));
          currentContent = "";
        }
        currentSection = paragraph.trim().replaceAll(':', '');
      } else {
        if (isFirstParagraph) {
          sections.add(Section(title: "About this Monument", content: paragraph.trim()));
          isFirstParagraph = false;
        } else {
          currentContent += (currentContent.isEmpty ? "" : "\n\n") + paragraph;
        }
      }
    }
    if (currentContent.isNotEmpty) {
      sections.add(Section(title: currentSection, content: currentContent.trim()));
    }
    if (sections.isEmpty || (sections.length == 1 && extract.length > 500)) {
      return _deduplicateSections(_createDefaultSections(extract));
    }
    
    return _deduplicateSections(sections);
  }
  List<Section> _deduplicateSections(List<Section> sections) {
    final result = <Section>[];
    final titles = <String>{};
    
    for (final section in sections) {
      if (titles.contains(section.title)) {
        if (section.title == "Overview" || section.title == "About this Monument") {
          result.add(Section(title: "Monument Details", content: section.content));
        } else {
          final existingIndex = result.indexWhere((s) => s.title == section.title);
          if (existingIndex >= 0) {
            final existing = result[existingIndex];
            result[existingIndex] = Section(
              title: existing.title,
              content: "${existing.content}\n\n${section.content}"
            );
          }
        }
      } else {
        result.add(section);
        titles.add(section.title);
      }
    }
    
    return result;
  }

  List<Section> _identifySectionsByKeywords(String extract) {
    List<Section> sections = [];
    List<String> commonSections = [
      "History", "Architecture", "Design", "Construction", 
      "Cultural significance", "Significance", "Tourism", 
      "Preservation", "Conservation", "In popular culture",
      "Description", "Features", "Location"
    ];

    String remainingText = extract;
    
    for (var keyword in commonSections) {
      int index = remainingText.indexOf(keyword);
      if (index != -1 && (index == 0 || remainingText[index-1] == ' ' || remainingText[index-1] == '\n')) {

        if (index > 0) {
          String previousContent = remainingText.substring(0, index).trim();
          if (previousContent.isNotEmpty) {
            sections.add(Section(title: "About this Monument", content: previousContent));
          }
        }

        int nextSectionIndex = remainingText.length;
        for (var nextKeyword in commonSections) {
          if (nextKeyword != keyword) {
            int nextIndex = remainingText.indexOf(nextKeyword, index + keyword.length);
            if (nextIndex != -1 && nextIndex < nextSectionIndex) {
              nextSectionIndex = nextIndex;
            }
          }
        }
        
        String content = remainingText.substring(index + keyword.length, nextSectionIndex).trim();
        sections.add(Section(title: keyword, content: content));
        remainingText = remainingText.substring(nextSectionIndex);
      }
    }
    if (remainingText.trim().isNotEmpty && sections.isNotEmpty) {
      sections.add(Section(title: "Additional Information", content: remainingText.trim()));
    }
    
    return sections;
  }
  List<Section> _createDefaultSections(String extract) {
    List<Section> sections = [];
    
    if (extract.length <= 800) {
      sections.add(Section(title: "About this Monument", content: extract.trim()));
    } else {
      final sentences = extract.split('. ');
      
      if (sentences.length >= 4) {
        int partSize = sentences.length ~/ 3; 
        
        String part1 = sentences.sublist(0, partSize).join('. ') + '.';
        String part2 = sentences.sublist(partSize, partSize * 2).join('. ') + '.';
        String part3 = sentences.sublist(partSize * 2).join('. ');
        
        sections.add(Section(title: "About this Monument", content: part1.trim()));
        sections.add(Section(title: "History & Features", content: part2.trim()));
        sections.add(Section(title: "Significance", content: part3.trim()));
      } else {
        int midpoint = extract.length ~/ 2;
        int breakPoint = extract.indexOf('. ', midpoint - 50);
        if (breakPoint == -1 || breakPoint > midpoint + 50) {
          breakPoint = midpoint;
        } else {
          breakPoint += 2; 
        }
        
        sections.add(Section(title: "About this Monument", content: extract.substring(0, breakPoint).trim()));
        sections.add(Section(title: "Additional Information", content: extract.substring(breakPoint).trim()));
      }
    }
    
    return sections;
  }
}