
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/staff_list_model.dart';
import '../data/models/user_list_model.dart';
import '../modules/members/member_controller.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({Key? key}) : super(key: key);

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final MembersController controller = Get.put(MembersController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoading.value) {
        controller.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // await controller.fetchCurrentTab(clear: true);
              controller.fetchInitial();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildTopToggle(),
              const SizedBox(height: 10),
              // Changed to Column for better layout
              _buildSearchAndFiltersColumn(),
              const SizedBox(height: 10),
              Expanded(child: _buildListView()),
              Obx(() => (controller.fromDate.value != null || controller.toDate.value != null)
                  ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Filter: ${controller.fromDate.value != null ? controller.displayFormat.format(controller.fromDate.value!) : '-'} → ${controller.toDate.value != null ? controller.displayFormat.format(controller.toDate.value!) : '-'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Clear'),
                    )
                  ],
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopToggle() {
    return Obx(
          () => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.activeTab.value == MemberTab.users
                    ? Get.theme.primaryColor
                    : Colors.white,
                foregroundColor: controller.activeTab.value == MemberTab.users
                    ? Colors.white
                    : Colors.black,
                elevation: controller.activeTab.value == MemberTab.users ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => controller.setActiveTab(MemberTab.users),
              child: const Text('Users', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.activeTab.value == MemberTab.doctors
                    ? Get.theme.primaryColor
                    : Colors.white,
                foregroundColor: controller.activeTab.value == MemberTab.doctors
                    ? Colors.white
                    : Colors.black,
                elevation:
                controller.activeTab.value == MemberTab.doctors ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => controller.setActiveTab(MemberTab.doctors),
              child: const Text('Doctors', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // New widget to arrange search and filters in a column
  Widget _buildSearchAndFiltersColumn() {
    return Column(
      children: [
        TextField(
          controller: controller.searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => controller.applyFiltersAndSearch(),
          decoration: InputDecoration(
            hintText: 'Search name, email or phone',
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.blueGrey),
              onPressed: () => controller.applyFiltersAndSearch(),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 10), // Space between search bar and filter button
        _buildFilterButton(),
      ],
    );
  }

  // Extracted filter button for cleaner code
  Widget _buildFilterButton() {
    return Obx(
          () => PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'this_month':
              controller.selectFilterThisMonth();
              break;
            case 'last_month':
              controller.selectFilterLastMonth();
              break;
            case 'last_week':
              controller.selectFilterLastWeek();
              break;
            case 'custom':
              await controller.showCustomDateRangePicker(context);
              break;
            case 'clear':
              controller.clearFilters();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'this_month', child: Text('This month')),
          const PopupMenuItem(value: 'last_month', child: Text('Last month')),
          const PopupMenuItem(value: 'last_week', child: Text('Last week')),
          const PopupMenuItem(value: 'custom', child: Text('Custom date range')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'clear', child: Text('Clear filters')),
        ],
        child: Container(
          width: double.infinity, // Make the button take full width
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              const Icon(Icons.filter_list, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                (controller.fromDate.value == null && controller.toDate.value == null)
                    ? 'Filter by Date'
                    : 'Date: ${controller.displayFormat.format(controller.fromDate.value ?? DateTime.now())} - ${controller.displayFormat.format(controller.toDate.value ?? DateTime.now())}',
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.blueGrey), // Add a dropdown icon
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildUserCard(UserListModel u) {
    final name = '${u.firstname ?? ''} ${u.lastname ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Stack( // Use Stack to position the more_vert icon
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'No name' : name,
                  style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Get.theme.primaryColor),
                ),
                const SizedBox(height: 8),
                _infoRow("Email", u.email),
                _infoRow("Phone", u.phone),
                _infoRow("Gender", u.gender),
                _infoRow("DOB", u.dob),
                _infoRow("Address", u.address),
                _infoRow("City", u.city),
                _infoRow("State", u.state),
                _infoRow("Country", u.country),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  controller.editUser(u);
                } else if (value == 'delete') {
                  controller.deleteUser(u);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDoctorCard(StaffListModel d) {
    final name = '${d.firstname ?? ''} ${d.lastname ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Stack( // Use Stack to position the more_vert icon
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'No name' : name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Get.theme.primaryColor),
                ),
                const SizedBox(height: 8),
                _infoRow("Email", d.email),
                _infoRow("Phone", d.phone),
                _infoRow("Gender", d.gender),
                _infoRow("DOB", d.dob),
                _infoRow("Address", d.address),
                _infoRow("City", d.city),
                _infoRow("State", d.state),
                _infoRow("Country", d.country),
                _infoRow("Pincode", d.pincode),
                _infoRow("Qualification", d.qualification),
                _infoRow("Specialization", d.specialization),
                _infoRow("Occupation", d.occupation),
                _infoRow("Professional Status", d.professionalStatus),
                _infoRow("WorkExperience TotalYears", d.workExperienceTotalYears?.toString()),
                _infoRow("WorkExperience LastHospital", d.workExperienceLastHospital),
                _infoRow("WorkExperience Position", d.workExperiencePosition),
                const Divider(height: 20, thickness: 1, color: Colors.grey,),
                const Text("Emergency Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _infoRow("Father's Name", d.fatherName),
                _infoRow("Mother's Name", d.motherName),
                _infoRow("Contact Name", d.emergencyContactName),
                _infoRow("Relation", d.emergencyContactRelation),
                _infoRow("Contact", d.emergencyContactContact),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  controller.editStaff(d);
                } else if (value == 'delete') {
                  controller.deleteStaff(d);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListView() {
    return Obx(() {
      final activeTab = controller.activeTab.value;
      final isLoading = controller.isLoading.value;

      if (activeTab == MemberTab.users) {
        final userList = controller.users;
        final usersHasMore = controller.usersHasMore.value;

        if (userList.isEmpty && isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (userList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => controller.fetchUsers(clear: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No users found')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchUsers(clear: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: userList.length + (usersHasMore ? 1 : 0),
            itemBuilder: (context, i) {
              if (i < userList.length) {
                return _buildUserCard(userList[i]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      } else {
        final doctorList = controller.doctors;
        final doctorsHasMore = controller.doctorsHasMore.value;

        if (doctorList.isEmpty && isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (doctorList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => controller.fetchDoctors(clear: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No staff found')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchDoctors(clear: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: doctorList.length + (doctorsHasMore ? 1 : 0),
            itemBuilder: (context, i) {
              if (i < doctorList.length) {
                return _buildDoctorCard(doctorList[i]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      }
    });
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}




