view: ticket {
  sql_table_name: `looker-private-demo.zendesk.ticket`;;
  drill_fields: [id, zendesk_user.name, account.account_name, reason, status, required_followup, created_date]

  #### Primary Key ####

  dimension: id {
    label: "ID"
    primary_key: yes
    type: string
    sql: substr(${TABLE}.id,0,10) ;;
    link: {
      label: "View Ticket on Zendesk"
      url: "https://looker-private-demo.zendesk.com"
    }
    link: {
      label: "View Case on Salesforce Service Cloud"
      url: "https://looker-private-demo.salesforce.com"
    }
    action: {
      label: "Update Zendesk Ticket"
      url: "https://hooks.zapier.com/hooks/catch/3604151/o24uzrp/"
      icon_url: "https://d1eipm3vz40hy0.cloudfront.net/images/logos/favicons/favicon.ico"
      param: {
        name: "Ticket ID"
        value: "718"
      }
      form_param: {
        name: "Status"
        type: select
        option: {
          name: "open"
          label: "open"
        }
        option: {
          name: "pending"
          label: "pending"
        }
        option: {
          name: "hold"
          label: "hold"

        }
        option: {
          name: "solved"
          label: "solved"
        }
        option: {
          name: "closed"
          label: "closed"
        }
        default: "{{ ticket.status }}"
      }
      form_param: {
        name: "Comment"
        type: textarea
      }
      form_param: {
        name: "Priority"
        type: select
        option: {
          name: "low"
          label: "low"
        }
        option: {
          name: "normal"
          label: "normal"
        }
        option: {
          name: "urgent"
          label: "urgent"
        }
        default: "{{ ticket.priority }}"
      }
    }
    action: {
      label: "Update Salesforce Case"
      url: "https://hooks.zapier.com/hooks/catch/3604151/o24uzrp/"
      icon_url: "https://www.salesforce.com/etc/designs/sfdc-www/en_us/favicon.ico"
      param: {
        name: "Ticket ID"
        value: "718"
      }
      form_param: {
        name: "Status"
        type: select
        option: {
          name: "open"
          label: "open"
        }
        option: {
          name: "pending"
          label: "pending"
        }
        option: {
          name: "hold"
          label: "hold"

        }
        option: {
          name: "solved"
          label: "solved"
        }
        option: {
          name: "closed"
          label: "closed"
        }
        default: "{{ ticket.status }}"
      }
      form_param: {
        name: "Comment"
        type: textarea
      }
      form_param: {
        name: "Priority"
        type: select
        option: {
          name: "low"
          label: "low"
        }
        option: {
          name: "normal"
          label: "normal"
        }
        option: {
          name: "urgent"
          label: "urgent"
        }
        default: "{{ ticket.priority }}"
      }
    }
    required_fields: [status, priority]
  }

  dimension: id_for_measures {
    # The "required fields" is causing the dimensions status and priority to be pulled into the GROUP BY of measures referencing id
    hidden: yes
    type: string
    sql: substr(${TABLE}.id,0,10) ;;
  }


  #### Foreign Keys ####

  dimension: group_id {
    hidden: yes
    type: string
    sql: ${TABLE}.group_id ;;
  }

  dimension: organization_id {
    hidden: yes
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: submitter_id {
    hidden: yes
    type: string
    sql: ${TABLE}.submitter_id ;;
  }

  dimension: requester_id {
    hidden: yes
    type: string
    sql: ${TABLE}.requester_id ;;
  }

  dimension: assignee_id {
    hidden: yes
    type: string
    sql: ${TABLE}.assignee_id ;;
  }


  #### Date Fields ####

  dimension_group: created {
    label: "Created"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      hour_of_day,
      day_of_week,
      month_name
    ]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  #### Other Dimensions ####

  dimension: action {
    label: "Action"
    description: "Action required from the ticket asignee"
    type: string
    sql:
    --case when ${TABLE}.action in ('one_off_sql','one_off_complex','only_feature_request','only_bug')
          case when ${TABLE}.action like '%bug%' or ${reason} like '%bug%' then 'bug submitted'
                when  ${TABLE}.action like '%feature_request%' or ${reason} = 'Feature Request' then 'feature request submitted'
          else replace(${TABLE}.action,'_',' ') end;;
  }

  dimension: issue_complexity_sort {
    hidden: yes
    type: string
    sql: case when ${TABLE}.issue_complexity = 'very_complex_issue' then 4
              when ${TABLE}.issue_complexity = 'complex_issue' then 3
              when ${TABLE}.issue_complexity = 'simple_issue' then 2
              when ${TABLE}.issue_complexity = 'very_simple_issue' then 1
            else null end
        ;;
  }

  dimension: issue_complexity {
    label: "Issue Complexity"
    view_label: "Tag"
    order_by_field: issue_complexity_sort
    type: string
    sql: case when ${TABLE}.issue_complexity = 'very_complex_issue' then 'Very Complex'
              when ${TABLE}.issue_complexity = 'complex_issue' then 'Complex'
              when ${TABLE}.issue_complexity = 'simple_issue' then 'Simple'
              when ${TABLE}.issue_complexity = 'very_simple_issue' then 'Very Simple'
            else null end;;
  }

  dimension: priority_sort {
    hidden: yes
    type: number
    sql: case when ${TABLE}.priority = 'urgent' then 1
              when ${TABLE}.priority = 'high' then 2
              when ${TABLE}.priority = 'normal' then 3
              when ${TABLE}.priority = 'low' then 4 end;;
  }

  dimension: priority {
    label: "Priority"
    order_by_field:  priority_sort
    type: string
    sql: ${TABLE}.priority ;;
  }

  dimension: reason {
    label: "Reason"
    view_label: "Tag"
    type: string
    sql: case when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) like '%bug%' then 'Bug'
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) like '%demo%' then 'Demo Request'
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) like '%feature%' then 'Feature Request'
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) = 'how_do_i_reason' then 'How do I...?'
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) = 'why_isn_t_this_working_reason' then "Why isn't this working?"
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) = 'other_reason' then 'Other'
              when coalesce(${TABLE}.reason, ${TABLE}.request_or_bug_) = 'not_a_support_request_reason' then 'Not a Support Request'
              else 'Unknown' end
    ;;
  }

  dimension: self_assessment_sort {
    label: "Self Assesment Sort"
    group_label: "Rating"
    hidden: yes
    type: string
    sql: case when ${TABLE}.self_assessment = 'very_negative_self_assessment' then 1
              when ${TABLE}.self_assessment = 'negative_self_assessment' then 2
              when ${TABLE}.self_assessment = 'netural_self_assessment' then 3
              when ${TABLE}.self_assessment = 'positive_self_assessment' then 4
              when ${TABLE}.self_assessment = 'very_positive_self_assessment' then 5 else null end;;
  }



  dimension: self_assessment {
    label: "Self Assesment"
    order_by_field: self_assessment_sort
    description: "How the chatter rated themselves, on a scale of 1-5 with 1 being Very Negative"
    type: string
    sql: case when ${TABLE}.self_assessment = 'very_negative_self_assessment' then 'Very Negative'
              when ${TABLE}.self_assessment = 'negative_self_assessment' then 'Very Positive'
              when ${TABLE}.self_assessment = 'netural_self_assessment' then 'Neutral'
              when ${TABLE}.self_assessment = 'positive_self_assessment' then 'Positive'
              when ${TABLE}.self_assessment = 'very_positive_self_assessment' then 'Very Positive' else null end;;
  }

  dimension: status {
    label: "Status"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: tone {
    label: "Tone"
    type: string
    sql: case when ${TABLE}.tone = 'happy' then 'positive'
              when ${TABLE}.tone in ('annoyed','angry','X') then 'very_negative'
              else ${TABLE}.tone end
            ;;
  }

  dimension: required_followup {
    label: "Required Followup"
    description: "Did the chat require an offline follow up?"
    type: yesno
    sql: ${TABLE}.required_followup =1;;
  }


  dimension: chat_duration {
    label: "Chat Duration"
    description: "The number of minutes that the chat lasted for"
    type: number
    sql: ${TABLE}.chat_duration;;
    value_format_name: decimal_2
  }

  dimension: chat_duration_tier {
    label: "Chat Duration Tier"
    description: "groups"
    type: tier
    sql: ${TABLE}.chat_duration;;
    style: integer
    tiers: [10,20,30]
  }


  dimension: via_channel {
    label: "Channel"
    description: "The channel that the ticket was submitted through"
    type: string
    sql: ${TABLE}.via_channel ;;
  }


  #### Measures ####

  measure: count {
    label: "Number of Tickets"
    type: count_distinct
    sql: ${id_for_measures} ;;
  }

  measure: urgent_tickets {
    label: "Number of Urgent Tickets"
    type: count
    filters: [priority: "urgent"]
  }


  measure: average_tickets_per_week {
    label: "Average Tickets Per Week"
    type: number
    sql: ${count}/nullif(count(distinct ${created_week}),0) ;;
    value_format_name: decimal_1
  }

  measure: average_chat_duration {
    label: "Average Chat Duration"
    type: average
    sql: ${chat_duration};;
    value_format_name: decimal_1
  }

  measure: count_fcr {
    hidden: yes
    type: count
    filters: [required_followup: "no"]
  }

  measure: first_contact_resolution {
    label: "FCR Rate"
    description: "First contact resolution rate, the percentage of tickets that did not require an offline follow up"
    type: number
    sql: ${count_fcr}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: average_self_assesment {
    label: "Average Self Assesment"
    group_label: "Rating"
    type: average
    sql: ${self_assessment_sort} ;;
    value_format_name: decimal_1
  }
}
