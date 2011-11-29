Rails.configuration.to_prepare do

  # Extend :account model to add :invoices association.
  Account.send(:include, AccountInvoiceAssociations)

  # Make invoices observable.
  ActivityObserver.instance.send :add_observer!, Invoice

  # Add :invoices plugin helpers.
  ActionView::Base.send(:include, InvoicesHelper)

end

# Make the invoices commentable.
CommentsController.commentables = CommentsController.commentables + %w(invoice_id)
