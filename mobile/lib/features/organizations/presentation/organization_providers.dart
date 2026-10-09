import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/organization_repository.dart';

final organizationRepositoryProvider = Provider((ref) => OrganizationRepository(Supabase.instance.client));
final organizationsProvider = FutureProvider<List<OrganizationRecord>>((ref) => ref.watch(organizationRepositoryProvider).listMine());
final selectedOrganizationProvider = StateProvider<String?>((_) => null);
