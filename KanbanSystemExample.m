%% Modeling a Kanban Production System

% Copyright 2015 The MathWorks, Inc.

%% Overview
%
% This example shows a production system that uses kanbans to manage
% production activities. Analysis of simulation results highlights problems
% in the system and suggests ways to improve its performance.
%
%%
model = 'seKanbanSystem';

subsystem1 = [model '/Assembly Line'];
subsystem2 = [model '/Part A Supplier'];
subsystem3 = [model '/Data Display'];
subsystem4 = [model '/Generate Production Orders'];

configkanban = [model '/ConfigKanban'];
configproduction = [model '/ConfigProduction'];

scope_len_wdr_B = [subsystem3 '/Number of Part B Withdrawal Kanban in Use'];
scope_wip_B = [subsystem3 '/Number of Part B in Process'];
scope_wip_P = [subsystem3 '/Number of Products in Final Assembly'];
scope_inv_B = [subsystem3 '/Number of Part B in Storage'];
scope_demand = [subsystem3 '/Product Demand' sprintf('\n') '(number of orders per day)'];
scope_ord_drop = [subsystem3 '/Number of Dropped Orders' sprintf('\n') '(year to date)'];

%% Structure of the Model
% The modeled production system includes two part suppliers and an assembly
% line. The part suppliers use raw materials to manufacture parts. Finished
% parts are transported to the assembly line to fabricate final products.
% Completed products are shipped to distributors to fill production orders.
open_system(model);
set_param(model, 'SimulationCommand', 'update');

%%
% At the top level of the model: 
% 
% * The Generate Production Orders subsystem simulates the generation of
% production orders.
% * The Assembly Line subsystem fills a production order by assembling two
% types of parts (referred to as part A and part B) into final products.
% * The Part A Supplier subsystem and Part B Supplier subsystem manufacture
% the parts needed for final assembly.
% * The Material A Supplier subsystem and Material B Supplier subsystem
% replenish the raw materials consumed during parts production.
%
%% Kanban Circulation
% "Kanban" comes from the Japanese word for "signboard". A kanban
% production system is a pull system that determines its production
% according to the actual demand of the customers. These systems use
% kanbans as demand signals that propagate through the production
% system to trigger and regulate production activities, such as processing
% and storage.
%
% This model simulates the circulation of two types of kanbans: withdrawal
% kanbans and work-in-process kanbans.
%
% * Withdrawal kanbans manage inventory. Withdrawal kanbans grant the right
% to withdraw parts from part suppliers to replenish inventory. Factory
% workers cannot remove the withdrawal kanban from a part in the existing
% inventory until the part is consumed. During production, the number of
% withdrawal kanbans issued for a type of parts is fixed. This limits the
% inventory size for that type of part. 
% * Work-in-process kanbans manage production. Work-in-process kanbans
% grant the right to manufacture parts in type and quantity as specified.
% After a part is produced, factory workers cannot remove the
% work-in-process kanban from the part until the part is withdrawn for
% final assembly. During production, the number of work-in-process kanbans
% issued for a type of parts is fixed. This limits the number of parts
% being processed by a part supplier.
% 
% Circulation of withdrawal kanbans for part A is modeled by the following
% blocks and subsystems:
%
% * Resource Acquirer block labeled Obtain Withdrawal Kanban in Part A
% Supplier subsystem
% * Resource Releaser block labeled Release Withdrawal Kanban A in Assembly
% Line subsystem
% * Resource Pool block labeled Withdrawal Kanban A
%
% The figures below show the Part A Supplier subsystem and Assembly Line
% subsystem.
%
open_system(subsystem2);
%%
close_system(subsystem2);
open_system(subsystem1);
%%
close_system(subsystem1);
%%
% During simulation, the block labeled Obtain Withdrawal Kanban in the Part
% A Supplier subsystem must obtain a withdrawal kanban before a part A is
% transported and stored for final assembly. When a part A in storage is
% consumed in final assembly, the block labeled Release Withdrawal Kanban A
% in the Assembly Line subsystem releases the withdrawal kanban. The kanban
% then returns to the block labeled Obtain Withdrawal Kanban to allow
% replenishment of part A inventory.
%
% Circulation of work-in-process kanbans is modeled in the same fashion as
% withdrawal kanbans. For example, in the Part A Supplier subsystem, the
% block labeled Obtain Work-in-process Kanban requests a work-in-process
% kanban upon producing a part A. After the part is completed and
% withdrawn, the block labeled Release Work-in-process Kanban releases the
% work-in-process kanban. The kanban then returns to the block labeled
% Obtain Work-in-process Kanban to allow the production of more of part A.
%
% The model uses Resource Pools to model the group of kanbans.
% To learn about this technique, see 
% <docid:simevents_ug#example-seExampleResourceAllocation>.
%
%% Dropped Orders
%
% A kanban production system reduces cost and waste by limiting inventories
% of work-in-process stock and finished products. However, when product
% demand fluctuates, lack of inventory may cause dropped orders.
%
% This model simulates dropped orders caused by seasonal demand
% fluctuations. In the |Generate Production Orders| subsystem, the Output
% Switch block labeled |Place Orders| uses |First port that is not blocked|
% as its switching criterion. During simulation, the block tries to send an
% order to the |Assembly Line| subsystem. If the inventory of finished
% product is empty, the block labeled |Fill Production Order| in the |Assembly
% Line| subsystem does not accept this order. The block labeled |Place
% Orders|
% then drops this order by forwarding it to the Entity Sink block labeled
% |Dropped Orders|.
open_system(subsystem4);
%% Results and Displays
close_system(subsystem4);
%%
% During simulation, the Data Display subsystem displays these scopes to
% show the performance of the production system:
%
% * Part A Withdrawal Kanban Backlog
% * Part B Withdrawal Kanban Backlog
% * Number of Part A in Process
% * Number of Part B in Process
% * Number of Products in Final Assembly
% * Number of Part A in Storage
% * Number of Part B in Storage
% * Product Demand
% * Number of Dropped Orders
% * Number of Completed Orders
%
% A Display block at the root level of the model provides a numeric view of
% the number of orders completed and the number of orders dropped.
%
%% Experimenting with the Model
% (_For use with live model only_)
%
% * Open the configuration dialog for product demand by double-clicking a
% configuration block in the colored region labeled Distributor. Change
% product demand by changing the *Daily product demand in each month of the
% year* parameter in this dialog.
% * Open the configuration dialog for the kanban system by double-clicking
% a configuration block in the colored region labeled Production System.
% Change the number of withdrawal kanbans and work-in-process kanbans
% issued for the production system by changing the parameters in this
% dialog.
% * Open the configuration dialog for production capability by
% double-clicking a configuration block in the colored region labeled
% Production System. Change the time it takes to manufacture, transport, and
% assemble parts or final products by changing the parameters in this
% dialog.
% * Open the configuration dialog for the material suppliers by
% double-clicking a configuration block in the colored region labeled
% Material Supplier. Change the time it takes to produce and deliver raw
% materials by changing the parameters in this dialog.
%
%% Using the Model for Performance Analysis
% The model with the original configuration represents a kanban production
% system with significant lost sales in months when demand is at a peak.
% Analysis of simulation results suggests solutions to address this issue.
%
% The following steps show how the solutions are developed.
%
% *Step 1:* Run the simulation using the original configuration. As shown
% in the figures below, the scope labeled Number of Dropped Orders
% indicates that the production system suffers significant lost sales
% between day 90 and day 150 of the year. Comparing this result with the
% scope labeled Product Demand indicates that lost sales happen when
% product demand is at a peak.
%%
sim(model);
open_system(scope_demand);
%%
close_system(scope_demand);
open_system(scope_ord_drop);
%%
close_system(scope_ord_drop);
%%
% *Step 2:* Comparing the demand in peak season with product supply
% indicates the assembly line does not provide sufficient production
% capability. According to the scope labeled Product Demand (see the figure
% above), 10 products are needed daily between day 90 and day 150. In
% contrast, as illustrated by the scope labeled Number of Products in Final
% Assembly (see the figure below), in the same period of time, only about 5
% are in production every day - much less than the quantity in demand.
open_system(scope_wip_P);
%%
close_system(scope_wip_P);
%%
% *Step 3:* Further observation of simulation results indicates that the
% inventory of part B is insufficient in the peak season. As illustrated by
% the scope labeled Number of Part B in Storage (see the figure below),
% inventory is empty in the peak season. This explains the inadequacy in
% the production capability during final assembly - the assembly line is
% not provided with sufficient part B.
open_system(scope_inv_B);
%%
close_system(scope_inv_B);
%%
% *Step 4:* Simulation results related to part B indicate that the use of
% withdrawal kanbans for part B is low in the peak season. This is displayed
% by the scope labeled Number of Part B Withdrawal Kanban in Use shown in
% the figure below.
open_system(scope_len_wdr_B);
%%
close_system(scope_len_wdr_B);
%%
% Use of withdrawal kanbans is reduced when the assembly line requests a
% replenishment but the part supplier fails to respond to this request in
% time. This leads to an analysis of the production capability of part B in
% the peak season of the year.
%
%%
% *Step 5:* The visual observations in the earlier steps suggest this
% quantitative analysis:
%
% * According to the scope labeled |Product Demand|, ten final products are
% required daily in the peak season.
% * Since 1 final product is assembled from one Part B and one Part A, to fully
% satisfy demand, ten Part Bs, are needed for final assembly per day. That is:
% 
%         Part B demand = 10 /day
% 
% * According to production capability configurations, it takes the part
% supplier 1.5 days to produce one part B. According to kanban system
% configurations, 12 work-in-process kanbans are issued for part B. This
% limits the maximal number of parts produced in parallel to 12. Thus, the
% maximal production rate of part B is:
%
%         Maximal part B production rate = 12/1.5 = 8 /day
%
%%
% *Step 6:* Comparing demand and maximal production rate of part B
% indicates the inadequacy in production capacity. Two possible solutions
% are:
%%
% * Issue more work-in-process kanbans for part B to allow more parts to be
% produced in parallel. To increase the maximal production rate of
% part B to above 10, issue at least 3 more work-in-process kanbans.
% * Reduce production cycle of part B to increase production rate.
% Production cycle needs to shorten by at least 0.3 day to meet required
% production rate.
%
%%
% *Step 7:* To verify solution 1, reconfigure the kanban system by
% increasing the *Number of work-in-process kanbans for part B* parameter
% to |15|. Simulation results indicate that with such an update, fifteen part Bs are
% produced in parallel (see the scope labeled Number of Part B in Process
% below). As indicated by the scope labeled Number of Dropped Orders, the
% increase in part B supply eliminates the occurrence of dropped orders.
set_param(configkanban,'NumWIPKanbanB','15');
sim(model);
open_system(scope_wip_B);
%%
close_system(scope_wip_B);
%%
open_system(scope_ord_drop);
%%
close_system(scope_ord_drop);
%%
% To verify solution 2, starting from the original configuration,
% reconfigure production capability by reducing the *Time it takes to
% produce a part B* parameter to |1.2| day. With the increase in production
% capability, 10 final products are in assembly daily (see the scope
% labeled Number of Products in Final Assembly below). As illustrated in
% the scope labeled Number of Dropped Orders below, such production
% capability can fully satisfy product demand, resulting in no loss of
% sales over the year.
set_param(configkanban,'NumWIPKanbanB','10');
set_param(configproduction,'DelayProduceB','1');
sim(model);
open_system(scope_wip_P);
%%
close_system(scope_wip_P);
%%
open_system(scope_ord_drop);
%%
close_system(scope_ord_drop);
%%
% The above steps explore the root cause of lost sales due to seasonal
% fluctuation in product demand. Quantitative analysis suggests two
% solutions to respond to such demand fluctuations. Simulation verifies
% that both solutions can indeed help the production system avoid seasonal
% lost sales.

%% 
%cleanup
bdclose(model);
clear model subsystem1 subsystem2 subsystem3 subsystem4 ...
    configkanban configproduction ...
    scope_len_wdr_A scope_len_wdr_B ...
    scope_wip_A scope_wip_B scope_wip_P ...
    scope_inv_A scope_inv_B ...
    scope_demand scope_ord_drop scope_ord_cmpl;
