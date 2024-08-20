SET STATISTICS IO ON;

/*
Скромные результаты наталкивают меня на мысль, что я чего-то не понимаю. И по этапам плана запроса ориентируюсь очень слабо. 
Подскажите пожалуйста точки с которыми нужно поработать.
*/
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
/*******       можно убрать этот джойн так как он не участвует в выдаче   выигрываем 30%     ********/
--JOIN Warehouse.StockItemTransactions AS ItemTrans
--		ON ItemTrans.StockItemID = det.StockItemID 
WHERE Inv.BillToCustomerID != ord.CustomerID 
/*******       пробовал перенести это условие в join, прироста мощности не увидел            ********/
AND (SELECT SupplierId FROM Warehouse.StockItems AS It WHERE It.StockItemID = det.StockItemID) = 12
/*******       пробовал перенести условие в CTE или join, но тоже не добился прироста        ********/
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)	FROM Sales.OrderLines AS Total JOIN Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
/******* тут пробовал простое сопоставление Inv.InvoiceDate = ord.OrderDate, но функция, как и ожидалось, работает лучше ********/
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
/******* сортировка также не влияет ********/
ORDER BY ord.CustomerID, det.StockItemID;


