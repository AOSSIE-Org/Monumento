import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/local_expert_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalExpertsCard extends StatefulWidget {
  final List<LocalExpertEntity> localExperts;
  final double width;
  const LocalExpertsCard({super.key, required this.localExperts, required this.width});

  @override
  State<LocalExpertsCard> createState() => _LocalExpertsCardState();
}

class _LocalExpertsCardState extends State<LocalExpertsCard> {
  @override
  Widget build(BuildContext context) {
    var width = widget.width;
    return Card(
      child: SizedBox(
        width: width ,
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (ctx, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  widget.localExperts[index].imageUrl,
                ),
              ),
              title: Text(widget.localExperts[index].name),
              subtitle: Text(
                widget.localExperts[index].designation,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () async {
                  if (await canLaunchUrl(
                    Uri.parse('tel:${widget.localExperts[index].phoneNumber}'),
                  )) {
                    launchUrl(
                      Uri.parse(
                          'tel:${widget.localExperts[index].phoneNumber}'),
                    );
                  } else {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                "Contact ${widget.localExperts[index].name}"),
                            content: Text(
                                "You can contact ${widget.localExperts[index].name} at ${widget.localExperts[index].phoneNumber}"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Close",
                                  style: AppTextStyles.s14(
                                      color: AppColor.appPrimary,
                                      fontType: FontType.MEDIUM,
                                      isDesktop: true),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
            );
          },
          separatorBuilder: (ctx, index) {
            return const Divider();
          },
          itemCount: widget.localExperts.length,
        ),
      ),
    );
  }
}
