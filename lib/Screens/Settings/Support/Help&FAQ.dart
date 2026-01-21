import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({Key? key}) : super(key: key);

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<_FaqItem> _faqs = [
    _FaqItem(
      category: 'Getting Started',
      question: 'Real Life RPG Overlay app kya hai?',
      answer:
      'Ye app aapki daily life ko RPG game ki tarah banata hai. Aap tasks ko “Quests” banate ho, complete karte ho, aur XP/Gold/Stats gain karte ho. Is se habit-building fun ho jati hai.',
    ),
    _FaqItem(
      category: 'Getting Started',
      question: 'Character ka role kya hai?',
      answer:
      'Character aapki progress represent karta hai (Level, XP, Stats). Jab aap quests complete karte ho to aapka character grow hota hai.',
    ),
    _FaqItem(
      category: 'Quests',
      question: 'Quest create kaise karun?',
      answer:
      'Quest tab ya Create button se aap title, description, difficulty (Easy/Medium/Hard), aur animation style set kar sakte ho. Save karte hi quest list mein show ho jata hai.',
    ),
    _FaqItem(
      category: 'Quests',
      question: 'Quest completion kaise hoti hai?',
      answer:
      'Aap manual complete kar sakte ho (checkbox / complete button). Future mein aap auto-detection add kar sakte ho (steps/location/app-usage based) jahan possible ho.',
    ),
    _FaqItem(
      category: 'AR',
      question: 'AR Character kaise kaam karta hai?',
      answer:
      'AR screen mein aapka selected character 3D model (Mixamo GLB) show hota hai. Aap Idle/Action animation toggle kar sakte ho. AR mode viewer ke andar AR icon se start hota hai.',
    ),
    _FaqItem(
      category: 'AR',
      question: 'AR mode start nahi ho raha, kya karun?',
      answer:
      'Ensure karein: (1) device AR-supported ho, (2) camera permission allow ho, (3) Android minSdk 24+ aur compileSdk 35 ho (agar Gradle error aa raha ho).',
    ),
    _FaqItem(
      category: 'Rewards',
      question: 'XP, Gold aur Stats ka kya use hai?',
      answer:
      'XP se level up hota hai, Gold future rewards/shop (optional) ke liye use ho sakta hai, aur Stats (Health/Strength/Intelligence) aapki habits ka gamified score hota hai.',
    ),
    _FaqItem(
      category: 'Social / Family',
      question: 'Family/Leaderboard ka purpose kya hai?',
      answer:
      'Family group ya friends ke saath motivation hoti hai. Leaderboard se progress compare hoti hai, aur challenges se fun competition create hota hai.',
    ),
    _FaqItem(
      category: 'Account & Data',
      question: 'Mera data kahan save hota hai?',
      answer:
      'Abhi basic version mein local data ho sakta hai. Backend integration ke baad (Firebase/Database) aapka data secure storage mein store hoga.',
    ),
    _FaqItem(
      category: 'Account & Data',
      question: 'Main apna account delete ya logout kaise karun?',
      answer:
      'Settings screen se Logout / Delete Account options milte hain. Delete account future backend implementation mein permanently remove karega.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    if (_query.trim().isEmpty) return _faqs;
    final q = _query.toLowerCase();
    return _faqs.where((f) {
      return f.category.toLowerCase().contains(q) ||
          f.question.toLowerCase().contains(q) ||
          f.answer.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Help & FAQ',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            SizedBox(height: AppSizes.paddingMD),

            _buildSearchBar(),
            SizedBox(height: AppSizes.paddingMD),

            _buildQuickActions(context),
            SizedBox(height: AppSizes.paddingLG),

            Text('Frequently Asked Questions', style: AppTextStyles.subheading),
            SizedBox(height: AppSizes.paddingSM),
            //
            // ..._buildFaqList(),
            //
            // SizedBox(height: AppSizes.paddingLG),
            // _buildContactSupport(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryPurple,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: AppShadows.glowPurple,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.whiteBackground.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(Icons.help_outline, color: AppColors.textWhite, size: 28),
          ),
          SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: AppTextStyles.headingWhite.copyWith(fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  'Find answers about Quests, AR, Rewards & more.',
                  style: AppTextStyles.bodyWhite.copyWith(
                    fontSize: 12,
                    color: AppColors.textWhite.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.primaryPurple),
          SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTextStyles.bodyDark,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search help (e.g., AR, quest, XP)',
                hintStyle: AppTextStyles.body,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: AppColors.textGray),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            title: 'How to Create Quest',
            icon: Icons.add_task,
            onTap: () => _scrollToCategory('Quests'),
          ),
        ),
        SizedBox(width: AppSizes.paddingSM),
        Expanded(
          child: _quickActionCard(
            title: 'AR Troubleshoot',
            icon: Icons.view_in_ar,
            onTap: () => _scrollToCategory('AR'),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingSM),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 22),
            ),
            SizedBox(width: AppSizes.paddingSM),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyDark.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFaqList() {
    final items = _filteredFaqs;

    if (items.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.whiteBackground,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 40, color: AppColors.textGray),
              SizedBox(height: AppSizes.paddingSM),
              Text('No results found', style: AppTextStyles.subheading),
              SizedBox(height: 4),
              Text(
                'Try searching with different keywords.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      ];
    }

    // group by category
    final Map<String, List<_FaqItem>> grouped = {};
    for (final f in items) {
      grouped.putIfAbsent(f.category, () => []).add(f);
    }

    final widgets = <Widget>[];
    grouped.forEach((category, list) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: AppSizes.paddingSM, bottom: AppSizes.paddingSM),
          child: Text(
            category,
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.textGray,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );

      widgets.addAll(list.map((f) => _faqTile(f)).toList());
    });

    return widgets;
  }

  Widget _faqTile(_FaqItem f) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: 4),
          childrenPadding: EdgeInsets.fromLTRB(
            AppSizes.padding,
            0,
            AppSizes.padding,
            AppSizes.padding,
          ),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(Icons.help, color: AppColors.textWhite, size: 20),
          ),
          title: Text(
            f.question,
            style: AppTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w700),
          ),
          iconColor: AppColors.primaryPurple,
          collapsedIconColor: AppColors.textGray,
          children: [
            Text(
              f.answer,
              style: AppTextStyles.body.copyWith(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Still need help?', style: AppTextStyles.subheading),
          SizedBox(height: 6),
          Text(
            'Agar aapko issue solve na ho to aap support ko message kar sakte hain (backend integrate hone ke baad).',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: AppSizes.padding),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Support messaging backend later add hoga.'),
                        backgroundColor: AppColors.primaryPurple,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Contact Support', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollToCategory(String category) {
    // Simple approach: just auto-fill search to category keyword
    // (easy to explain, no complex scroll controllers needed)
    _searchController.text = category;
    setState(() => _query = category);
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}