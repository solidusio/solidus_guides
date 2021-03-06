---
title: Payment States
---

## Introduction

When an order is initiated for a customer purchase a payment is created in the Solidus system. A payment goes through various states while being processed.

## Payment States

The possible payment states are:

* **Checkout** - The checkout has not been completed.
* **Processing** - The payment is being processed.
* **Pending** - The payment has been processed but is not yet complete (ex. authorized but not captured).
* **Failed** - The payment was rejected (ex. credit card was declined).
* **Void** - The payment should not be applied against the order.
* **Completed** -  The payment is completed. Only payments in this state count against the order total.

A payment does not necessarily go through each of these states in sequential order as illustrated below:

![Payments Flow]({{ site.baseurl }}/assets/img/users/payments/payment_flow.jpg)

You can determine the payment state for a particular order by going to the Admin Interface and clicking on the "Orders" tab. Find the order you want to look up and there will be a column which specifies it under "Payment State".

You can find the order payment details by clicking on the specific order state url in the "Payment State column"

![Payment Details]({{ site.baseurl }}/assets/img/users/payments/payment_details.png)

## Authorize vs Capture

Authorizing a payment is the process of confirming the availability of funds for a transaction with the purchaser's credit card company. Capturing a payment is the process of telling the credit card company that you would like to get paid for the transaction amount. Typically, this two step process of first authorizing the payment and then capturing the payment is used by online retailers to delay charging the customer until the product(s) purchased are fulfilled (shipped).

By default, Solidus automatically handles authorizing the payment for a transaction. For capturing payments, we give you the choice of auto-capturing the payment or manually capturing the payment via the Admin Interface. If you like, you can read further [documentation about auto-capturing payments]({{ site.baseurl }}/developer/payments#auto-capturing).

Note: Not all payment gateways allow for the two step *authorize and then capture* payment process. If this functionality is required for your store, please confirm with your payment gateway that they can support this process.

# Capture a Payment via the Admin

To capture a payment using the Admin Interface, click on the "Orders" tab. Find the order you want to look up and click on it. Then click on the "Payments" link. The order details will appear. Click on the "Capture" icon to initiate the capture process.

![Capture a Payment]({{ site.baseurl }}/assets/img/users/payments/payment_capture.png)

## Void a Payment

To void a payment, go to the Admin Interface. click on the "Orders" tab. Find the order you want to look up and click on it. Then click on the "Payments" link. The order details will appear. Click on the "Void" icon to void the transaction.

![Void a Payment]({{ site.baseurl }}/assets/img/users/payments/payment_void.png)
