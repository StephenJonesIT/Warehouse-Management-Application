import 'dart:convert';
import 'package:bai1/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  String? selectedTransactionType;
  String searchQuery = '';

  final List<String> transactionTypes = ['all', 'in', 'out'];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      if (currentPage == 1) {
        transactions.clear();
      }
      isLoading = true;
    });

    try {
      String typeFilter = selectedTransactionType == 'all' || selectedTransactionType == null
          ? ''
          : '&type=${selectedTransactionType}';
      String searchFilter = searchQuery.isNotEmpty
          ? '&search=$searchQuery'
          : '';

      final response = await http.get(Uri.parse(
          'https://manage-sale-microservice.onrender.com/api/transactions?page=$currentPage&limit=$pageSize$typeFilter$searchFilter'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> transactionData = data['data'];
        totalItems = data['filter']['total'];

        setState(() {
          transactions.addAll(
              transactionData.map((json) => Transaction.fromJson(json)).toList());
          filteredTransactions = List.from(transactions);
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load transactions')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!isLoadingMore && transactions.length < totalItems) {
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });
      await _fetchTransactions();
    }
  }

  void _filterTransactions() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        final matchesType = selectedTransactionType == null ||
            selectedTransactionType == 'all' ||
            transaction.transactionType == selectedTransactionType;

        final matchesSearch = searchQuery.isEmpty ||
            transaction.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            transaction.warehouseName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            transaction.transactionId.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesType && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TransactionSearchDelegate(transactions: transactions),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedTransactionType != null || searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (selectedTransactionType != null)
                    Chip(
                      label: Text(
                        'Type: ${selectedTransactionType!.toUpperCase()}',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getTransactionTypeColor(selectedTransactionType!),
                      onDeleted: () {
                        setState(() {
                          selectedTransactionType = null;
                          _filterTransactions();
                        });
                      },
                    ),
                  if (searchQuery.isNotEmpty)
                    Chip(
                      label: Text(
                        'Search: $searchQuery',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                      onDeleted: () {
                        setState(() {
                          searchQuery = '';
                          _filterTransactions();
                        });
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (isLoading && transactions.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          currentPage = 1;
        });
        await _fetchTransactions();
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: filteredTransactions.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < filteredTransactions.length) {
            return buildTransactionItem(filteredTransactions[index]);
          } else if (isLoadingMore) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget buildTransactionItem(Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isInbound = transaction.transactionType == 'in';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getTransactionTypeColor(transaction.transactionType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              isInbound ? 'IN' : 'OUT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          transaction.productName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Warehouse: ${transaction.warehouseName}'),
            Text('ID: ${transaction.transactionId}'),
            Text('Date: ${dateFormat.format(transaction.transactionDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isInbound ? '+' : '-'}${transaction.quantity}',
              style: TextStyle(
                color: isInbound ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetail(context, transaction);
        },
      ),
    );
  }

  Color _getTransactionTypeColor(String type) {
    switch (type) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showTransactionDetail(BuildContext context, Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isInbound = transaction.transactionType == 'in';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', transaction.transactionId),
              _buildDetailRow('Product', transaction.productName),
              _buildDetailRow('Warehouse', transaction.warehouseName),
              _buildDetailRow('Type',
                isInbound ? 'INBOUND' : 'OUTBOUND',
                color: isInbound ? Colors.green : Colors.red,
              ),
              _buildDetailRow('Quantity',
                '${isInbound ? '+' : '-'}${transaction.quantity}',
                color: isInbound ? Colors.green : Colors.red,
              ),
              _buildDetailRow('Date', dateFormat.format(transaction.transactionDate)),
              SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isInbound ? Colors.green[100] : Colors.red[100],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: transaction.quantity / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isInbound ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Transactions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Transaction Type'),
                  DropdownButton<String>(
                    value: selectedTransactionType ?? 'all',
                    items: transactionTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTransactionType = value == 'all' ? null : value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _filterTransactions();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class TransactionSearchDelegate extends SearchDelegate {
  final List<Transaction> transactions;

  TransactionSearchDelegate({required this.transactions});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Transaction> results = transactions.where((transaction) {
      final matchesQuery = transaction.productName.toLowerCase().contains(query.toLowerCase()) ||
          transaction.warehouseName.toLowerCase().contains(query.toLowerCase()) ||
          transaction.transactionId.toLowerCase().contains(query.toLowerCase());
      return matchesQuery;
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Transaction> suggestions = query.isEmpty
        ? []
        : transactions.where((transaction) {
      final matchesQuery = transaction.productName.toLowerCase().contains(query.toLowerCase()) ||
          transaction.warehouseName.toLowerCase().contains(query.toLowerCase()) ||
          transaction.transactionId.toLowerCase().contains(query.toLowerCase());
      return matchesQuery;
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<Transaction> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final transaction = results[index];
        final isInbound = transaction.transactionType == 'in';

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isInbound ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isInbound ? 'IN' : 'OUT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(transaction.productName),
          subtitle: Text('${transaction.warehouseName} - ${transaction.transactionId}'),
          trailing: Text(
            '${isInbound ? '+' : '-'}${transaction.quantity}',
            style: TextStyle(
              color: isInbound ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            close(context, transaction);
          },
        );
      },
    );
  }
}