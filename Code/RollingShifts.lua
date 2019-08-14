local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

local happy_workers = {}
local unhappy_workers = {}

function OnMsg.NewWorkshift(shift)
  local container = UICity.labels.Workplace
  if container == nil then return end

  CreateGameTimeThread(function()
    local othershifts = {}

    for othershift=1,3 do
      if othershift == shift then goto next_shift end
      othershifts[#othershifts + 1] = othershift
      ::next_shift::
    end

    print("Finding unhappy workers at", RealTime(), "in shifts", othershifts)

    local WorkDarkHoursSanityDecrease = g_Consts.WorkDarkHoursSanityDecrease
    local OutsideWorkplaceSanityDecrease = g_Consts.OutsideWorkplaceSanityDecrease
    local martianborn_resilience = UICity:IsTechResearched("MartianbornResilience")

    for _, workers in pairs(happy_workers) do
      for k in pairs(workers) do
        workers[k] = nil
      end
    end
    for _, workers in pairs(unhappy_workers) do
      for k in pairs(workers) do
        workers[k] = nil
      end
    end

    for _, workplace in ipairs(container) do
      local outside_sanity_decrease = not workplace.parent_dome and not BreathableAtmosphere and OutsideWorkplaceSanityDecrease
      for _, othershift in ipairs(othershifts) do
        local overtime = workplace.overtime[othershift]
        local dark_penalty = othershift == 3 and WorkDarkHoursSanityDecrease
        for _, worker in pairs(workplace.workers[othershift]) do
          local sanity = worker:GetSanity()
          local specialist = worker.specialist
          local traits = worker.traits
          local happy = true
          if overtime and not traits.Workaholic then
            happy = false
          elseif outside_sanity_decrease and not (martianborn_resilience and traits.Martianborn) then
            happy = false
          elseif dark_penalty then
            happy = false
          end
          local list
          if happy and sanity > 50 then
            if not happy_workers[specialist] then
              happy_workers[specialist] = {}
            end
            list = happy_workers[specialist]
          elseif not happy and sanity < 50 then
            if not unhappy_workers[specialist] then
              unhappy_workers[specialist] = {}
            end
            list = unhappy_workers[specialist]
          else
            goto next_worker
          end
          list[#list + 1] = worker
          ::next_worker::
        end
      end
    end

    print("Built list of unhappy workers at", RealTime())

    for speciality, unhappy_specialists in pairs(unhappy_workers) do
      if #unhappy_specialists == 0 then goto next_speciality end

      local happy_specialists = happy_workers[speciality]
      if not happy_specialists or #happy_specialists == 0 then goto next_speciality end

      print(speciality, #happy_specialists, #unhappy_specialists)

      --table.sort(happy_specialists, function (a,b) return a.stat_sanity > b.stat_sanity end)
      table.sortby_field_descending(happy_specialists, 'stat_sanity')
      
      --table.sort(unhappy_specialists, function (a,b) return a.stat_sanity < b.stat_sanity end)
      table.sortby_field(unhappy_specialists, 'stat_sanity')

      for i = #unhappy_specialists,1,-1 do
        local worker = unhappy_specialists[i]
        local worker_workplace = worker.workplace
        local worker_shift = worker.workplace_shift

        local victim_index = #happy_specialists

        local victim = happy_specialists[victim_index]
        local victim_workplace = victim.workplace
        local victim_shift = victim.workplace_shift

        while worker_workplace == victim_workplace and worker_shift == victim_shift do
          victim_index = victim_index - 1
          if victim_index == 0 then goto next_worker end
          victim = happy_specialists[victim_index]
          victim_workplace = victim.workplace
          victim_shift = victim.workplace_shift
        end

        if Mods.mrudat_TestingMods then
          orig_print("swapping", table.concat(worker.name), worker:GetSanity(), "with", table.concat(victim.name), victim:GetSanity())
        end

        victim_workplace:RemoveWorker(victim)
        worker:SetWorkplace(victim_workplace, victim_shift)
        victim:SetWorkplace(worker_workplace, worker_shift)

        -- this should be cheap-ish, as victim_index almost always == #happy_specialists
        table.remove(happy_specialists, victim_index)

        if #happy_specialists == 0 then goto next_speciality end
        ::next_worker::
      end

      print("swapped unhappy", speciality, "at", RealTime())

      ::next_speciality::
    end
  end)
end

orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
