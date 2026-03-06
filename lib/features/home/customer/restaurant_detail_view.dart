import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/services/cart_service.dart';
import 'package:speakdine_app/models/menu_item_model.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';
import 'package:speakdine_app/services/speech_service.dart';
import 'package:speakdine_app/services/llm_intent_service.dart';
import 'package:intl/intl.dart';
import 'cart_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final Map restaurantObj;
  const RestaurantDetailView({super.key, required this.restaurantObj});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final DatabaseService _dbService = DatabaseService();
  final CartService _cartService = CartService();
  final SpeechService _speechService = SpeechService();
  
  bool _isListening = false;
  List<MenuItemModel> _allMenuItems = [];


  Color _parseColor(dynamic colorData) {
    if (colorData == null) return colorExt.primaryContainer;
    if (colorData is int) return Color(colorData);
    if (colorData is String) {
      if (colorData.startsWith('0x')) {
        return Color(int.parse(colorData));
      }
      if (colorData.startsWith('#')) {
        return Color(int.parse(colorData.replaceFirst('#', '0xFF')));
      }
      return Color(int.parse('0xFF$colorData'));
    }
    return colorExt.primaryContainer;
  }

  @override
  void initState() {
    super.initState();
    _speechService.init();
  }

  @override
  Widget build(BuildContext context) {
    String restaurantId = widget.restaurantObj["id"] ?? "";
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildInfoSection(theme),
          _buildMenuSections(restaurantId, theme),
          _buildReviewsSection(restaurantId, theme),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120))
        ],
      ),
      floatingActionButton: _buildFABs(context, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onSpeechResult(String text) {
    if (!_speechService.isListening) {
      _processVoiceCommand(text);
    }
  }

  void _processVoiceCommand(String text) async {
    final response = await LLMIntentService.parseIntent(text);
    final String intent = response['intent'] ?? "UNKNOWN";
    final String msg = response['message'] ?? "I couldn't understand that.";

    if (intent == "PLACE_ORDER") {
       for (var item in _allMenuItems) {
         if (text.toLowerCase().contains(item.name.toLowerCase())) {
           _cartService.addToCart(item, widget.restaurantObj["id"] ?? "");
           _speechService.speak("Added ${item.name} to your cart.");
           if (mounted) PremiumSnackbar.show(context, message: "Added ${item.name} via voice");
           return;
         }
       }
       _speechService.speak("I couldn't find that item in the menu. Please try again.");
    } else if (intent == "MAKE_PAYMENT") {
       if (_cartService.items.isNotEmpty) {
         Navigator.push(context, PremiumPageTransition(page: const CartView()));
       } else {
         _speechService.speak("Your cart is empty. Add something first.");
       }
    } else {
       _speechService.speak(msg);
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      bool ok = await _speechService.startListening(
        onResultText: _onSpeechResult,
      );
      if (ok) {
        setState(() => _isListening = true);
        _speechService.speak("Listening for your order.");
      }
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340, // Massive header
      pinned: true,
      stretch: true,
      backgroundColor: colorExt.surface,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: "restaurant_image_${widget.restaurantObj["name"]}",
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.restaurantObj["profile_picture"] != null 
                ? Image.network(widget.restaurantObj["profile_picture"], fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      color: _parseColor(widget.restaurantObj["color"]),
                    ),
                    child: Icon(Icons.storefront_rounded, size: 100, color: Colors.white.withValues(alpha: 0.3)),
                  ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.restaurantObj["username"] ?? "Restaurant", 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w900, 
                        fontFamily: 'Metropolis', 
                        fontSize: 32,
                        height: 1.1
                      ),
                    ).animate().slideY(begin: 0.2, duration: 600.ms),
                    const SizedBox(height: 8),
                     Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            const Text("4.8", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          ]),
                        ),
                        const SizedBox(width: 12),
                        const Text("•  Pakistani", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        const Text("•  30-40 min", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                      ],
                    ).animate().slideY(begin: 0.2, delay: 100.ms, duration: 600.ms)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorExt.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorExt.primaryContainer)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.delivery_dining_rounded, "Free", "Delivery"),
              Container(height: 40, width: 1, color: colorExt.primary.withValues(alpha: 0.2)),
              _buildInfoItem(Icons.timer_rounded, "35 mins", "Time"),
              Container(height: 40, width: 1, color: colorExt.primary.withValues(alpha: 0.2)),
              _buildInfoItem(Icons.location_on_rounded, "2.5 km", "Distance"),
            ],
          ),
        ).animate().scale(curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: colorExt.primary, size: 24),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w800, fontSize: 14)),
        Text(subtitle, style: TextStyle(color: colorExt.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMenuSections(String restaurantId, ThemeData theme) {
    if (restaurantId.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return StreamBuilder<List<MenuItemModel>>(
      stream: _dbService.streamMenuItemsForRestaurant(restaurantId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
        
        _allMenuItems = snapshot.data!;
        if (_allMenuItems.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text("Menu coming soon!")));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                 return Padding(
                   padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                   child: Text("Full Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorExt.primaryText)),
                 );
              }
              var item = _allMenuItems[index - 1];
              return _buildMenuItem(item, restaurantId, theme)
                  .animate(delay: (index * 50).ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutBack, duration: 500.ms);
            },
            childCount: _allMenuItems.length + 1,
          ),
        );
      }
    );
  }

  Widget _buildMenuItem(MenuItemModel item, String restaurantId, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (){}, // Detail view provided?
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  color: colorExt.secondaryContainer,
                  child: item.imageUrl != null 
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.fastfood_rounded, size: 40, color: colorExt.secondaryText),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                        const SizedBox(height: 8),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text("Rs. ${item.price.toStringAsFixed(0)}", 
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                             
                             InkWell(
                               onTap: () {
                                  _cartService.addToCart(item, restaurantId);
                                  PremiumSnackbar.show(context, message: "${item.name} added");
                               },
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: theme.colorScheme.primaryContainer,
                                   borderRadius: BorderRadius.circular(12)
                                 ),
                                 child: Text("ADD", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 12)),
                               ),
                             )
                           ],
                         )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(String restaurantId, ThemeData theme) {
    if (restaurantId.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.streamReviewsForRestaurant(restaurantId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        final reviews = snapshot.data!;
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                 return Padding(
                   padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                   child: Text("Customer Reviews (${reviews.length})", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorExt.primaryText)),
                 );
              }
              final review = reviews[index - 1];
              final customerName = review['customerName'] ?? "Anonymous";
              final rating = (review['rating'] ?? 0).toInt();
              final comment = review['comment'] ?? "";
              final reply = review['reply'] as String?;
              dynamic createdAt = review['createdAt'];
              String dateStr = "Unknown Date";
              if (createdAt != null) {
                if (createdAt is! DateTime) createdAt = createdAt.toDate();
                dateStr = DateFormat('MMM d, yyyy').format(createdAt);
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorExt.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: colorExt.primary.withValues(alpha: 0.1),
                              child: Text(
                                customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                                style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          ],
                        ),
                        Text(dateStr, style: TextStyle(color: colorExt.secondaryText, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        Icons.star_rounded, 
                        size: 16, 
                        color: i < rating ? Colors.amber : colorExt.outlineVariant.withValues(alpha: 0.5)
                      )),
                    ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(comment, style: TextStyle(color: colorExt.primaryText, fontSize: 13, height: 1.4)),
                    ],
                    if (reply != null && reply.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorExt.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorExt.primaryContainer.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.reply_rounded, size: 16, color: colorExt.primary),
                                const SizedBox(width: 8),
                                Text("Response from Owner", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorExt.primary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(reply, style: TextStyle(fontSize: 13, color: colorExt.primaryText)),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              );
            },
            childCount: reviews.length + 1,
          ),
        );
      }
    );
  }

  Widget _buildFABs(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _toggleListening,
          backgroundColor: _isListening ? Colors.red : colorExt.primary,
          foregroundColor: Colors.white,
          heroTag: "mic_fab",
          child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
        ).animate(target: _isListening ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 500.ms),
        const SizedBox(height: 16),
        _buildCartFAB(context, theme),
      ],
    );
  }

  Widget _buildCartFAB(BuildContext context, ThemeData theme) {
    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, child) {
        if (_cartService.items.isEmpty) return const SizedBox();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, PremiumPageTransition(page: const CartView()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text("${_cartService.itemCount} Items", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Text("View Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text("Rs. ${_cartService.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    ).animate().slideY(begin: 1.0, end: 0, curve: Curves.easeOutBack, duration: 800.ms);
  }
}
