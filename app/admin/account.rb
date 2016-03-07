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
      render "admin/accounts/entries", account: account
    end

    panel "Entries (auto)" do
      per_page = 50
      last_page = (account.entries.count / per_page.to_f).ceil
      page = params[:entries_page] || last_page
      entries = account.entries.page(page).per(per_page)

      paginated_collection(entries, param_name: 'entries_page') do
        table_for entries do
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
            # NOTE: this only works because we're using integers for IDs. Move
            # to window functions to get this working properly.
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
    end

  end

end
