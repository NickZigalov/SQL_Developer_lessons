SET STATISTICS IO ON

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
--, ItemTrans.*
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
		ON ItemTrans.StockItemID = det.StockItemID 
WHERE Inv.BillToCustomerID != ord.CustomerID 
AND (SELECT SupplierId FROM Warehouse.StockItems AS It WHERE It.StockItemID = det.StockItemID) = 12
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)	FROM Sales.OrderLines AS Total JOIN Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID




Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
--, ItemTrans.*
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
--JOIN Warehouse.StockItemTransactions AS ItemTrans
--		ON ItemTrans.StockItemID = det.StockItemID 
WHERE Inv.BillToCustomerID != ord.CustomerID 
--AND (SELECT SupplierId FROM Warehouse.StockItems AS It WHERE It.StockItemID = det.StockItemID) = 12
--AND (SELECT SUM(Total.UnitPrice*Total.Quantity)	FROM Sales.OrderLines AS Total JOIN Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID



SELECT ord.CustomerID, det.StockItemID, SUM(det.UnitPrice*det.Quantity)	
	FROM Sales.OrderLines AS det 
		JOIN Sales.Orders AS ord ON ord.OrderID = det.OrderID 
		JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID and ord.CustomerID = Inv.CustomerID
		WHERE 
			 Inv.BillToCustomerID != ord.CustomerID
			 AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
	GROUP BY ord.CustomerID, det.StockItemID
	HAVING SUM(det.UnitPrice*det.Quantity)>250000




Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice*det.Quantity)--, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
--JOIN Warehouse.StockItemTransactions AS ItemTrans
--		ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems AS It ON It.StockItemID = det.StockItemID and It.SupplierId=12
WHERE 
	Inv.BillToCustomerID != ord.CustomerID 
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)	FROM Sales.OrderLines AS Total JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
	AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
--ORDER BY ord.CustomerID, det.StockItemID
