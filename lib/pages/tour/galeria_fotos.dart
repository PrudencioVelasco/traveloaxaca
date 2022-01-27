import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_collapse/gallery_item.dart';
import 'package:image_collapse/gallery_thumbnail.dart';
import 'package:image_collapse/gallery_view_wrapper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:traveloaxaca/models/imagen_tour.dart';
import 'package:traveloaxaca/models/tour.dart';

enum DisplayType {
  ListView,
  StaggeredGridView,
}

class GaleriaFotoTourPage extends StatefulWidget {
  final Tour tour;
  GaleriaFotoTourPage({Key? key, required this.tour}) : super(key: key);

  @override
  _GaleriaFotoTourPageState createState() => _GaleriaFotoTourPageState();
}

class _GaleriaFotoTourPageState extends State<GaleriaFotoTourPage> {
  static const NUM_IMAGE_COLLAPSE = 4;
  static final List<GalleryItem> _galleryItems = <GalleryItem>[];
  static const MAX_LOAD_MORE = 10;

  List<String>? imageUrls;
  String? titleGallery;
  TextStyle? remainNumberStyle;
  int? crossAxisCount;
  double? mainAxisSpacing;
  double? crossAxisSpacing;
  BoxDecoration? backgroundImageView;
  Color? fadingColorCollapse;
  Color? appBarColor;
  DisplayType? displayType;
  Size? imageSize;
  EdgeInsetsGeometry? padding;

  @override
  void initState() {
    bindingToGalleryItem(widget.tour.imagenestour);
    displayType = DisplayType.StaggeredGridView;
    imageSize = const Size(double.infinity, 150);
    crossAxisCount = 6;
    mainAxisSpacing = 4.0;
    crossAxisSpacing = 4.0;
    titleGallery = widget.tour.nombre.toString();
    super.initState();
  }

  bindingToGalleryItem(List<ImagenTour>? imageUrls) {
    _galleryItems.clear();
    var imageName, tagId;
    imageUrls!.forEach((imageUrl) {
      imageName = imageUrl.nombreimagen;
      tagId = DateTime.now().microsecondsSinceEpoch;
      _galleryItems.add(
        GalleryItem(
          id: imageUrl.idimagentour.toString(),
          imageUrl: imageUrl.url.toString(),
        ),
      );
    });
  }

  Widget _buildLoading() {
    return CupertinoActivityIndicator();
  }

  Widget _buildImageCollapses() {
    int imageUrlsLength = widget.tour.imagenestour!.length;
    switch (displayType) {
      case DisplayType.ListView:
        return ListView.builder(
          itemCount: imageUrlsLength,
          padding: padding,
          itemBuilder: (context, index) {
            return Card(
              child: Container(
                height: imageSize!.height,
                width: imageSize!.width,
                child: GalleryThumbnail(
                  galleryItem: _galleryItems[index],
                  onTap: () => openImageFullScreen(context, index),
                ),
              ),
            );
          },
        );
      case DisplayType.StaggeredGridView:
      default:
        return StaggeredGridView.countBuilder(
          crossAxisCount: crossAxisCount!,
          mainAxisSpacing: mainAxisSpacing!,
          crossAxisSpacing: crossAxisSpacing!,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          itemCount: imageUrlsLength > NUM_IMAGE_COLLAPSE
              ? NUM_IMAGE_COLLAPSE
              : imageUrlsLength,
          itemBuilder: (context, int index) {
            return Container(
              height: 252,
              child: imageUrlsLength > NUM_IMAGE_COLLAPSE && index == 3
                  ? buildImageNumbers(context, index)
                  : GalleryThumbnail(
                      galleryItem: _galleryItems[index],
                      onTap: () => openImageFullScreen(context, index),
                    ),
            );
          },
          staggeredTileBuilder: (int index) => StaggeredTile.count(
            crossAxisCellCount(imageUrlsLength, index),
            mainAxisCellCount(imageUrlsLength, index),
          ),
        );
    }
  }

  int crossAxisCellCount(int length, int index) {
    if (length == 1)
      return 6;
    else if (length == 2)
      return 3;
    else if (length == 3) {
      if (index < 1) return 6;
      return 3;
    } else {
      if (index < 1) return 6;
      return 2;
    }
  }

  double mainAxisCellCount(int galleryLength, int index) {
    if (galleryLength == 1) {
      return 4;
    } else if (galleryLength != 2) {
      if (index == 0) return 3;
    }
    return 2;
  }

  Widget buildImageNumbers(
    context,
    int indexOfImage,
  ) {
    int remainNumberImage = widget.tour.imagenestour!.length - indexOfImage;
    return GestureDetector(
      onTap: () => openImageFullScreen(context, indexOfImage),
      child: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: [
          GalleryThumbnail(
            galleryItem: _galleryItems[indexOfImage],
          ),
          Container(
            color: fadingColorCollapse ?? Colors.black.withOpacity(0.7),
            alignment: Alignment.center,
            child: Text(
              "+$remainNumberImage",
              style: remainNumberStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void openImageFullScreen(context, int indexOfImage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return GalleryViewWrapper(
          appBarColor: appBarColor,
          titleGallery: titleGallery,
          galleryItem: _galleryItems,
          backgroundDecoration: backgroundImageView ??
              const BoxDecoration(color: Color(0xff374056)),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.tour.nombre.toString(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: widget.tour.imagenestour!.length == 0
            ? _buildLoading()
            : _buildImageCollapses());
  }

  PhotoViewGalleryPageOptions _buildImage(BuildContext context, int index) {
    final gallery = widget.tour.imagenestour![index];
    final minScale = PhotoViewComputedScale.contained * 0.8;
    final maxScale = PhotoViewComputedScale.covered * 8;
    return PhotoViewGalleryPageOptions.customChild(
        minScale: minScale,
        maxScale: maxScale,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: gallery.idimagentour!),
        child: CachedNetworkImage(
          imageUrl: gallery.url!,
          placeholder: (_, __) => const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ));
  }
}
