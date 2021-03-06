function vsConditions = GetConditionList()

   vsConditions = {
         1, 'cGO_target';
        10, 'cGO_baseline';
         2, 'sSTOP_target'; % successful stop trials
        20, 'sSTOP_baseline'; % baseline successful stop trials
         3, 'cAC_target';   % correct AC trials         
        30, 'cAC_baseline';   % baseline correct AC trials
         5, 'fSTOP_target'; % failed stop trials
        50, 'fSTOP_baseline'; % baseline failed stop trials
   };

end
