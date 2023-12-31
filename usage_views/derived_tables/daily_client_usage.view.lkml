view: daily_client_usage {
  derived_table: {
    datagroup_trigger: event_trigger
    partition_keys: ["event_date"]
    sql: SELECT
              date(timestamp(DATETIME_SUB(event_logs.timestamp, INTERVAL (DATE_DIFF(date '2020-05-03', current_date(), DAY)) DAY))) as event_date,
              client_id as client_id,
              COUNT(*) AS total_event_count,
              SUM(if(event_logs.log.cs_uri_query.uri like '%dashboards%'  or  event_logs.log.cs_uri_query.uri like '%looks%'
                  or event_logs.log.cs_uri_query.uri like '%presentation%',1,0)) as  dashboard_events,
              SUM(if(event_logs.log.cs_uri_query.uri like '%embed%'  or  event_logs.log.cs_uri_query.uri like '%stories%'
                  or event_logs.log.cs_uri_query.uri like '%browse%' or event_logs.log.cs_uri_query.uri like '%spaces%',1,0)) as  browse_events,
              SUM(if(event_logs.log.cs_uri_query.uri like '%explore%',1,0)) as  explore_events,
              SUM(if(event_logs.log.cs_uri_query.uri like '%projects%' or event_logs.log.cs_uri_query.uri like '%sql%',1,0)) as  model_events,
              SUM(if(event_logs.log.cs_uri_query.uri like '%admin%',1,0)) as  admin_events,

              COUNT( DISTINCT if(event_logs.log.cs_uri_query.uri like '%dashboards%'  or event_logs.log.cs_uri_query.uri like '%looks%'
                                  or event_logs.log.cs_uri_query.uri like '%presentation%',event_logs.user_id,null)) as  dashboard_users,
              COUNT( DISTINCT if(event_logs.log.cs_uri_query.uri like '%embed%'  or  event_logs.log.cs_uri_query.uri like '%stories%'
                    or event_logs.log.cs_uri_query.uri like '%browse%' or event_logs.log.cs_uri_query.uri like '%spaces%',event_logs.user_id,null)) as  browse_users,
              COUNT( DISTINCT if(event_logs.log.cs_uri_query.uri like '%explore%',event_logs.user_id,null)) as  explore_users,
              COUNT( DISTINCT if(event_logs.log.cs_uri_query.uri like '%projects%' or event_logs.log.cs_uri_query.uri like '%sql%',event_logs.user_id,null)) as  model_users,
              COUNT( DISTINCT if(event_logs.log.cs_uri_query.uri like '%admin%',event_logs.user_id,null)) as  admin_users,

              COUNT(DISTINCT ( event_logs.user_id )) AS distinct_users
          FROM ${event_logs.SQL_TABLE_NAME} AS event_logs
          group by 1,2;;
  }

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(cast(${event_date} as string),'|'${client_id}) ;;
  }

  dimension_group: event {
    hidden: yes
    type: time
    sql: timestamp(${TABLE}.event_date) ;;
  }

  dimension: client_id {
    hidden: yes
    type: string
    sql: ${TABLE}.client_id ;;
  }

  ## event counts ###

  dimension: total_event_count {
    label: "Total Event Count"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.total_event_count ;;
  }

  dimension: dashboard_events {
    label: "Dashboard Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.dashboard_events  ;;
  }

  dimension: browse_events {
    label: "Browse Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.browse_events ;;
  }

  dimension: explore_events {
    label: "Explore Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.explore_events ;;
  }

  dimension: model_events {
    label: "Model Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.model_events  ;;
  }

  dimension: admin_events {
    label: "Admin Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${TABLE}.admin_events ;;
  }

  dimension: other_events {
    label: "Other Events"
    group_label: "Daily Event Counts"
    type: number
    sql: ${total_event_count} - (${admin_events} + ${explore_events} + ${browse_events}  + ${model_events}  + ${dashboard_events});;
  }


## user counts ###

  dimension: distinct_users {
    group_label: "Daily User Counts"
    label: "Total Users"
    type: number
    sql: ${TABLE}.distinct_users ;;
  }

  dimension: dashboard_users {
    label: "Dashboard Users"
    group_label: "Daily User Counts"
    type: number
    sql: ${TABLE}.dashboard_users ;;
  }

  dimension: explore_users {
    label: "Explore Users"
    group_label: "Daily User Counts"
    type: number
    sql: ${TABLE}.explore_users ;;
  }

  dimension: model_users {
    label: "Model Users"
    group_label: "Daily User Counts"
    type: number
    sql: ${TABLE}.model_users ;;
  }

  dimension: browse_users {
    label: "Browse Users"
    group_label: "Daily User Counts"
    type: number
    sql: ${TABLE}.browse_users ;;
  }

  dimension: admin_users {
    label: "Admin Users"
    group_label: "Daily User Counts"
    type: number
    sql: ${TABLE}.admin_users ;;
  }

  dimension: percent_active_users {
    label: "Percent Active Users"
    type: number
    sql: ${distinct_users}/nullif(${daily_user_count.named_user_count},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_active_tier {
    label: "Percent Active Tier"
    type: tier
    sql: ${percent_active_users}*100;;
    style: integer
    tiers: [25,50,75,100]
  }

  dimension: total_event_per_user_tier {
    label: "Total Event Per User Tier"
    type: tier
    sql: ${total_event_count}/${distinct_users};;
    style: integer
    tiers: [50,100,500,1000,2000]
  }


  ### Event Total Measures ###

  measure: sum_total_event_count {
    label: "Sum Total Event Count"
    group_label: "Event Counts"
    type: sum
    sql: ${total_event_count} ;;
  }

  measure: sum_dashboard_events {
    label: "Sum Dashboard Events"
    group_label: "Event Counts"
    type: sum
    sql: ${dashboard_events} ;;
  }

  measure: sum_explore_events {
    label: "Sum Explore Events"
    group_label: "Event Counts"
    type: sum
    sql: ${explore_events} ;;
  }

  measure: sum_model_events {
    label: "Sum Model Events"
    group_label: "Event Counts"
    type: sum
    sql: ${model_events} ;;
  }

  measure: sum_browse_events {
    label: "Sum Browse Events"
    group_label: "Event Counts"
    type: sum
    sql: ${browse_events} ;;
  }

  measure: sum_admin_events {
    label: "Sum Admin Events"
    group_label: "Event Counts"
    type: sum
    sql: ${admin_events} ;;
  }

  measure: sum_other_events {
    label: "Sum Other Events"
    group_label: "Event Counts"
    type: sum
    sql: ${other_events} ;;
  }

### Percent of Total Event Counts ###

  measure: percent_dashboard_events {
    label: "Percent Dashboard Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_dashboard_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }

  measure: percent_explore_events {
    label: "Percent Explore Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_explore_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }

  measure: percent_model_events {
    label: "Percent Model Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_model_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }

  measure: percent_browse_events {
    label: "Percent Browse Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_browse_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }

  measure: percent_admin_events {
    label: "Percent Admin Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_admin_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }

  measure: percent_other_events {
    label: "Percent Other Events"
    group_label: "Percent of Event Counts"
    type: number
    sql: ${sum_other_events} / nullif(${sum_total_event_count},0);;
    value_format_name: percent_1
  }


## Average User Measures ###

  measure: average_distinct_users {
    group_label: "Average Daily User Counts"
    label: "Average Daily Users"
    type: average
    sql: ${distinct_users} ;;
    value_format_name: decimal_1
  }

  measure: average_dashboard_users {
    label: "Average Dashboard Users"
    group_label: "Average Daily User Counts"
    type: average
    sql: ${dashboard_users} ;;
    value_format_name: decimal_1

  }

  measure: average_explore_users {
    label: "Average Explore Users"
    group_label: "Average Daily User Counts"
    type: average
    sql: ${explore_users} ;;
    value_format_name: decimal_1

  }

  measure: average_model_users {
    label: "Average Model Users"
    group_label: "Average Daily User Counts"
    type: average
    sql: ${model_users} ;;
    value_format_name: decimal_1

  }

  measure: average_browse_users {
    label: "Average Browse Users"
    group_label: "Average Daily User Counts"
    type: average
    sql: ${browse_users} ;;
    value_format_name: decimal_1

  }

  measure: average_admin_users {
    label: "Average Admin Users"
    group_label: "Average Daily User Counts"
    type: average
    sql: ${admin_users};;
    value_format_name: decimal_1

  }


  ### Percent of All Active Users ###


  measure: average_percent_dashboard_users {
    label: "Average Percent Dashboard Users"
    group_label: "Average Daily Percent of User"
    type: average
    sql: ${dashboard_users} / nullif(${distinct_users},0);;
    value_format_name: percent_1
  }

  measure: average_percent_explore_users {
    label: "Average Percent Explore users"
    group_label: "Average Daily Percent of User"
    type: average
    sql: ${explore_users} / nullif(${distinct_users},0);;
    value_format_name: percent_1
  }

  measure: average_percent_model_users {
    label: "Average Percent Model Users"
    group_label: "Average Daily Percent of User"
    type: average
    sql: ${model_users} / nullif(${distinct_users},0);;
    value_format_name: percent_1
  }

  measure: average_percent_browse_users {
    label: "Average Percent Browse Users"
    group_label: "Average Daily Percent of User"
    type: average
    sql: ${browse_users} / nullif(${distinct_users},0);;
    value_format_name: percent_1
  }

  measure: average_percent_admin_users {
    label: "Average Percent Admin Users"
    group_label: "Average Daily Percent of User"
    type: average
    sql: ${admin_users} / nullif(${distinct_users},0);;
    value_format_name: percent_1
  }

  measure: average_percent_active_users {
    label: "Average Percent Active Users"
    group_label: "Average Daily Percent of User"
    type: average
    sql:${percent_active_users};;
    value_format_name: percent_1
  }

}
