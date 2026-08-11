import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _TeamAsset {
  const _TeamAsset(this.path, this.isSvg);

  final String path;
  final bool isSvg;
}

const Map<String, _TeamAsset> _teamAssets = {
  'OB': _TeamAsset('assets/images/teams/doosan.svg', true),
  'DOOSAN': _TeamAsset('assets/images/teams/doosan.svg', true),
  'LG': _TeamAsset('assets/images/teams/lg.svg', true),
  'HT': _TeamAsset('assets/images/teams/kia.png', false),
  'KIA': _TeamAsset('assets/images/teams/kia.png', false),
  'SS': _TeamAsset('assets/images/teams/samsung.svg', true),
  'SAMSUNG': _TeamAsset('assets/images/teams/samsung.svg', true),
  'SK': _TeamAsset('assets/images/teams/ssg.png', false),
  'SSG': _TeamAsset('assets/images/teams/ssg.png', false),
  'LT': _TeamAsset('assets/images/teams/lotte.svg', true),
  'LOTTE': _TeamAsset('assets/images/teams/lotte.svg', true),
  'HH': _TeamAsset('assets/images/teams/hanwha.svg', true),
  'HANWHA': _TeamAsset('assets/images/teams/hanwha.svg', true),
  'NC': _TeamAsset('assets/images/teams/nc.svg', true),
  'KT': _TeamAsset('assets/images/teams/kt.svg', true),
  'WO': _TeamAsset('assets/images/teams/kiwoom.png', false),
  'KIWOOM': _TeamAsset('assets/images/teams/kiwoom.png', false),
};

/// KBO 구단 로고. 알 수 없는 [teamCode]는 이니셜 뱃지로 대체합니다.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.teamCode, this.size = 24});

  final String teamCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = _teamAssets[teamCode.toUpperCase()];
    if (asset == null) {
      return _FallbackBadge(teamCode: teamCode, size: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: asset.isSvg
          ? SvgPicture.asset(asset.path, width: size, height: size)
          : Image.asset(
              asset.path,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
    );
  }
}

class _FallbackBadge extends StatelessWidget {
  const _FallbackBadge({required this.teamCode, required this.size});

  final String teamCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.primaries[teamCode.hashCode % Colors.primaries.length],
        shape: BoxShape.circle,
      ),
      child: Text(
        teamCode.isEmpty ? '?' : teamCode.substring(0, 1),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
