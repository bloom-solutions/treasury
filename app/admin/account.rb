ActiveAdmin.register Plutus::Account, as: "Account" do

  TYPES = {
    "Asset" => "Plutus::Asset",
    "Liability" => "Plutus::Liability",
    "Equity" => "Plutus::Equity",
    "Revenue" => "Plutus::Revenue",
    "Expense" => "Plutus::Expense",
  }

  actions :all, except: [:destroy]
  permit_params :name, :type, :contra

  index do
    column(:type) { |account| TYPES.invert[account.type] }
    column :name
    column :balance
    actions
  end

  form do |f|
    inputs do
      f.input :name
      f.input :type, collection: TYPES, include_blank: false
    end
    actions
  end

  show do
    attributes_table do
      row(:type) { |account| TYPES.invert[account.type] }
      row :name
      row :contra
    end

    active_admin_comments

    panel "Entries" do
      table_for account.entries do
        column(:date)
        column(:id)
        column(:description)
        column("Decrease") do |entry|
          if account.normal_credit_balance
            entry.debit_amounts.where(account_id: account.id).sum(:amount)
          else
            entry.credit_amounts.where(account_id: account.id).sum(:amount)
          end
        end
        column("Increase") do |entry|
          if account.normal_credit_balance
            entry.credit_amounts.where(account_id: account.id).sum(:amount)
          else
            entry.debit_amounts.where(account_id: account.id).sum(:amount)
          end
        end
        column("Balance") do |entry|
          # NOTE: this only works because we're using integers for IDs
          credit_sum =
            account.credit_amounts.where("entry_id <= ?", entry.id).sum(:amount)
          debit_sum =
            account.debit_amounts.where("entry_id <= ?", entry.id).sum(:amount)

          if account.normal_credit_balance
            credit_sum - debit_sum
          else
            debit_sum - credit_sum
          end
        end
      end
    end

    # panel "New Entry" do
    #   render "admin/entries/new", account: resource
    # end
    panel "Credit #{account.name}" do
    #   form Plutus::Entry.new do |f|
    #     f.input :description
    #     f.input :date, as: :string, input_html: {class: "datepicker"}
    #     f.semantic_fields_for :credits do |credit|
    #       credit.inputs "Credit 1" do
    #         credit.input :account_name, collection: Plutus::Account.all.pluck(:name)
    #         credit.input :amount
    #       end
    #       credit.inputs "Credit 2" do
    #         credit.input :account_name, collection: Plutus::Account.all.pluck(:name)
    #         credit.input :amount
    #       end
    #     end
    #   end
    end
  end

end
